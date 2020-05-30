defmodule Annoyer.Filter.Drop do
    @behaviour Annoyer.Filter

    @impl true
    def filter(params, annoyence) when is_list(params) do
        params
        |> Map.new()
        |> filter(annoyence)
    end

    @impl true
    def filter(%{condition: condition} = params, annoyence) do
        case condition.(annoyence) do
            false -> params |> Map.delete(:condition) |> filter(annoyence)
            true -> :drop
        end
    end

    @impl true
    def filter(_params, annoyence), do: {:ok, annoyence}
end