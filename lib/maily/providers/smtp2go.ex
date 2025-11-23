defmodule Maily.Providers.Smtp2Go do
  @base_url "https://api.smtp2go.com/v3/email/send"

  def send(to, template) do
    payload = %{
      sender: template[:from],
      to: [to],
      subject: template[:subject],
      html_body: template[:html_body]
    }

    {:ok, json_body} = Jason.encode(payload)

    headers = [
      {"Content-Type", "application/json"},
      {"X-Smtp2go-Api-Key", Application.get_env(:maily, :smtp2go)[:api_key]},
      {"Accept", "application/json"}
    ]

    case HTTPoison.post(@base_url, json_body, headers) do
      {:ok, _} ->
        :ok

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
