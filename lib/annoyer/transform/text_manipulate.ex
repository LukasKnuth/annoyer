defmodule Annoyer.Transform.TextManipulate do
  @behaviour Annoyer.Transform

  @impl true
  def transform(params, annoyence) when is_list(params) do
    # Parameter-list to map, let matching do the rest
    params
    |> Map.new()
    |> transform(annoyence)
  end

  @impl true
  def transform(%{prepend: prepend} = params, annoyence) do
    params
    |> Map.delete(:prepend)
    |> transform(%{annoyence | content: prepend <> annoyence.content})
  end

  @impl true
  def transform(%{append: append} = params, annoyence) do
    params
    |> Map.delete(:append)
    |> transform(%{annoyence | content: annoyence.content <> append})
  end

  # Ends the chain of recursive calls from above.
  @impl true
  def transform(_params, annoyence), do: {:ok, annoyence}
end
