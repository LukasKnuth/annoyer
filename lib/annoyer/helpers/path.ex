defmodule Annoyer.Helpers.Path do
  @type annoyence() :: Annoyer.Annoyence.t
  @type path() :: term|list(term)

  @spec fetch(path :: path, data :: annoyence) :: {:ok, any} | :error
  def fetch(path, data) when is_list(path) do
    case get_in(data, Enum.map(path, &make_lookup(&1))) do
      :error = err -> err
      result -> {:ok, result}
    end
  end

  def fetch(key, data), do: fetch([key], data)

  @doc """
  This creates a lookup function for use with the Kernel.get_in/2 function, which uses Access.fetch/2 to check if a value
   exists and returns an explicit :error symbol in such cases.
  While not 100% safe, this makes it more likely to differentiate between nil values and actually missing keys.
  """
  defp make_lookup(key) do
    fn :get, data, next ->
      with {:ok, result} <- Access.fetch(data, key), do: next.(result)
    end
  end

  @spec get(path :: path, data :: annoyence, fallback :: any) :: any
  def get(path, data, fallback) do
    case fetch(path, data) do
      {:ok, result} -> result
      :error -> fallback
    end
  end

  @spec put(path :: path, data :: annoyence, value :: any) :: any
  def put(path, data, value) when is_list(path) do
    put_in(data, path, value)
  end

  def put(key, data, value), do: put([key], data, value)

end
