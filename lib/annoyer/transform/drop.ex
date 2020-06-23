defmodule Annoyer.Transform.Drop do
  @behaviour Annoyer.Transform

  @impl true
  def transform(params, annoyence) when is_list(params) do
    params
    |> Map.new()
    |> transform(annoyence)
  end

  @impl true
  def transform(%{condition: condition} = params, annoyence) do
    case condition.(annoyence) do
      false -> params |> Map.delete(:condition) |> transform(annoyence)
      true -> :drop
    end
  end

  @impl true
  def transform(_params, annoyence), do: {:ok, annoyence}
end
