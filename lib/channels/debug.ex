defmodule DebugChannel do
    use Annoyer.Channel

    outgoing Annoyer.Outgoing.Console
end
