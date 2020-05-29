defmodule Annoyer.Filter.TextManipulate do
  @behaviour Annoyer.Filter

  @impl true
  def filter(params, annoyence) when is_list(params) do
    # Parameter-list to map, let matching to the rest
    params
    |> Map.new()
    |> filter(annoyence)
  end

  @impl true
  def filter(%{prepend: prepend} = params, annoyence) do
    params
    |> Map.delete(:prepend)
    |> filter(%{annoyence | content: prepend <> annoyence.content})
  end

  @impl true
  def filter(%{append: append} = params, annoyence) do
    params
    |> Map.delete(:append)
    |> filter(%{annoyence | content: annoyence.content <> append})
  end

  @impl true
  def filter(_params, annoyence) do
    # Ends the chain of recursive calls from above.
    annoyence
  end
end
