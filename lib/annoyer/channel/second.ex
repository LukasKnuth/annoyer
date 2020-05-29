defmodule Annoyer.Channel.Second do
  use Annoyer.Channel

  topic "info"

  filter Annoyer.Filter.TextManipulate, prepend: "Second: "

  outgoing Annoyer.Outgoing.Console

end