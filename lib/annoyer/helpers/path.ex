defmodule Annoyer.Helpers.Path do

  @spec fetch(path :: keyword(), data:: any) :: {:ok, any} | :error
  def fetch([key | rest], data) do
    with {:ok, found} <- Map.fetch(data, key),
      do: fetch(rest, found)
  end

  def fetch([], data), do: data

  @spec get(path :: keyword(), data :: any, fallback :: any) :: any
  def get(path, data, fallback) do
    case fetch(path, data) do
      {:ok, result} -> result
      :error -> fallback
    end
  end

end
