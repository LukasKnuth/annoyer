defmodule Annoyer.Channel.Second do
  use Annoyer.Channel

  topic("info")

  transform(Annoyer.Transform.TextManipulate, prepend: "Second: ")

  outgoing(Annoyer.Outgoing.Console)
end
