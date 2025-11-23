defmodule Maily.Cloudevent do
  def validate?(
        %{"specversion" => spec, "id" => id, "source" => source, "type" => type} = _cloudevent
      )
      when is_binary(spec) and spec != "" and
             is_binary(id) and id != "" and
             is_binary(source) and source != "" and
             is_binary(type) and type != "" do
    if spec == "1.0" do
      :ok
    else
      {:error, "CloudEvents version unsupported"}
    end
  end

  def validate?(_), do: {:error, "CloudEvents entries are missing"}
end
