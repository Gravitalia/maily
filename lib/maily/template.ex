defmodule Maily.Template do
  def read_template(locale, name) do
    path = "../../templates/#{locale}/#{name}.json"
    relative_path = Path.join([path])
    filepath = Path.expand(relative_path, __DIR__)

    case File.read(filepath) do
      {:ok, json_string} ->
        json_map = Jason.decode!(json_string, keys: :atoms)
        {:ok, json_map}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
