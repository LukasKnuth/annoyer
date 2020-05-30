defmodule Annoyer.Filter do
  @callback filter(params :: keyword(), annoyence :: Annoyer.Annoyence.t()) ::
              {:ok, Annoyer.Annoyence.t()} | :drop
end
