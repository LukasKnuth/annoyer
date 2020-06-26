defmodule Annoyer.Helpers.Path do

  @spec extract(path :: keyword(), data :: any, fallback :: any) :: any
  def extract([key | rest], data, fallback) do
    case Map.fetch(data, key) do
      {:ok, found} -> extract(rest, found, fallback)
      :error -> fallback
    end
  end

  def extract([], result, _fallback), do: result

  def extract(key, data, fallback), do: Map.get(data, key, fallback)

end
