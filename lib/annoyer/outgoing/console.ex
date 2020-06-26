defmodule Annoyer.Outgoing.Console do
  @behaviour Annoyer.Outgoing
  alias Annoyer.Helpers.Path

  @impl true
  def output(params, annoyence) when is_list(params) do
    params
    |> Map.new
    |> output(annoyence)
  end

  def output(%{keys: keys}, annoyence) when is_list(keys) do
    extras =
      keys
      |> Enum.map(fn path ->
        data = Path.extract(path, annoyence, :not_found)
        "-> #{format_path(path)}: #{inspect data}"
      end)
      |> Enum.join("\n")
    IO.puts("#{annoyence.topic}: #{annoyence.content}\n#{extras}")
  end

  def output(_params, annoyence) do
    IO.puts("#{annoyence.topic}: #{annoyence.content}")
  end

  defp format_path(path) do
    Enum.join(path, ".")
  end
end
