defmodule Maily do
  use Broadway

  require Logger
  alias Broadway.Message

  defp config do
    Application.get_env(:maily, :rabbitmq)
  end

  def start_link(_opts) do
    cfg = config()

    Broadway.start_link(__MODULE__,
      name: Maily.Pipeline,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: cfg[:queue],
           declare: [
            durable: true,
           ],
           connection: [
             host: cfg[:host],
             port: cfg[:port],
             username: cfg[:username],
             password: cfg[:password]
           ],
           qos: [
             prefetch_count: cfg[:prefetch]
           ],
           on_success: :ack,
           on_failure: :reject_and_requeue_once},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: cfg[:concurrency]]
      ]
    )
  end

  @impl true
  def handle_message(_, %Message{} = message, _) do
    message
    |> parse_and_validate_message()
  end

  defp parse_and_validate_message(%Message{data: raw_data} = message) do
    case Jason.decode(raw_data) do
      {:ok, cloudevent} ->
        case Maily.Cloudevent.validate?(cloudevent) do
          :ok ->
            Logger.debug("received cloudevent", cloudevent: cloudevent)

            {:ok, datetime, 0} = DateTime.from_iso8601(cloudevent["time"])
            {:ok, utc_datetime} = DateTime.shift_zone(datetime, "Etc/UTC")

            cloudevent_data = cloudevent["data"]
            locale = cloudevent_data["locale"] || "en"

            {:ok, date} = Cldr.DateTime.to_string(utc_datetime, locale: locale, format: :long)

            case Maily.Template.read_template(
                   locale,
                   cloudevent_data["template"]
                 ) do
              {:ok, template} ->
                html_body = template[:html_body]
                updated_html_body = html_body |> String.replace("[[date]]", date)|> String.replace("[[username]]", cloudevent_data["username"] || "")
                updated_template = %{template | :html_body => updated_html_body}

                case Maily.Providers.Smtp2Go.send(cloudevent_data["to"], updated_template) do
                  :ok ->
                    Logger.debug("email sent")
                    message |> Message.put_data(cloudevent)

                  {:error, reason} ->
                    Logger.error("SMTP send failed", reason: reason)
                    message |> Message.failed(reason)
                end

              {:error, reason} ->
                Logger.error("failed to read or decode template", reason: inspect(reason))
                message |> Message.failed("Template read error: #{inspect(reason)}")
            end

          {:error, reason} ->
            Logger.error("invalid cloudevent received", reason: reason, cloudevent: cloudevent)
            message |> Message.failed(reason)
        end

      {:error, reason} ->
        Logger.error("failed to decode JSON", reason: reason, raw_data: raw_data)
        message |> Message.failed("JSON decode error: #{inspect(reason)}")
    end
  end
end
