defmodule Annoyer.Outgoing do
  @callback output(params :: keyword(), annoyence :: Annoyer.Annoyence.t()) :: none
end
