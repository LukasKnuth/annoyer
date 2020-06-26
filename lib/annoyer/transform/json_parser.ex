defmodule Annoyer.Transform.JsonParser do
  @behaviour Annoyer.Transform
  alias Annoyer.Helpers.Path
  require Logger

  def transform(params, annoyence) when is_list(params) do
    params |> Map.new |> transform(annoyence)
  end

  def transform(%{body_path: body_path} = params, annoyence) do
    params = Map.delete(params, :body_path)
    result = with {:ok, body} <- Path.fetch(body_path, annoyence),
         do: Jason.decode(body)
    case result do
      {:ok, parsed} ->
        {:ok, handle_parsed(params, parsed, annoyence)}
      :error ->
        Logger.warn("Couldn't find JSON body at body_path #{inspect(body_path)}")
        :drop
      {:error, reason} ->
        Logger.error("Couldn't parse JSON", reason)
        :drop
    end
  end

  defp handle_parsed(%{json_path: json_path} = params, parsed, annoyence) do
    params = Map.delete(params, :json_path)
    case ExJSONPath.eval(parsed, json_path) do
      {:ok, matches} -> handle_parsed(params, matches, annoyence)
      {:error, reason} ->
        Logger.error("Couldn't evaluated JSON Path", reason)
        handle_parsed(params, parsed, annoyence)
    end
  end

  defp handle_parsed(params, parsed, annoyence) when is_list(parsed) do
    Enum.map(parsed, &handle_parsed(params, &1, annoyence))
  end

  defp handle_parsed(_params, parsed, annoyence) do
    %{annoyence | attachments: Map.put(annoyence.attachments, :json, parsed)}
  end
end
