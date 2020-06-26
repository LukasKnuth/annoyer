defmodule Annoyer.Transform.ToString do
  @behaviour Annoyer.Transform
  alias Annoyer.Helpers.Path

  @defaults %{target: :content, join: " "}

  @impl true
  def transform(params, annoyence) when is_list(params) do
    params = Map.new(params)

    @defaults
    |> Map.merge(params)
    |> do_transform(annoyence)
  end

  defp do_transform(%{target: target_path, sources: source_paths, join: join_str}, annoyence) when is_list(source_paths) do
    value = source_paths
      |> Enum.map(&stringify(Path.get(&1, annoyence, :not_found)))
      |> Enum.join(join_str)
    {:ok, Path.put(target_path, annoyence, value)}
  end

  defp do_transform(%{target: target_path, source: source_path}, annoyence) do
    value = Path.get(source_path, annoyence, :not_found)
    {:ok, Path.put(target_path, annoyence, stringify(value))}
  end

  defp stringify(value) do
    if str = String.Chars.impl_for(value) do
      str.to_string(value)
    else
      inspect(value)
    end
  end

end
