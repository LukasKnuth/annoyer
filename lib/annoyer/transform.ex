defmodule Annoyer.Transform do
  @callback transform(params :: keyword(), annoyence :: Annoyer.Annoyence.t()) ::
              {:ok, Annoyer.Annoyence.t() | list(Annoyer.Annoyence.t())} | :drop
end
