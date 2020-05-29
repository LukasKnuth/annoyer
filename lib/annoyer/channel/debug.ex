defmodule Annoyer.Channel.Debug do
    use Annoyer.Channel

    filter Annoyer.Filter.TextManipulate, prepend: "Hello, ", append: " and World"
    filter Annoyer.Filter.TextManipulate, append: "..."

    outgoing Annoyer.Outgoing.Console
end
