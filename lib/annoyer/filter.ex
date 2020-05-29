defmodule Annoyer.Filter do
  @callback filter(params :: keyword(), annoyence :: Annoyer.Annoyence.t()) ::
              Annoyer.Annoyence.t()
end
