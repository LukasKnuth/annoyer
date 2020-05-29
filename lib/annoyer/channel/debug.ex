defmodule Annoyer.Channel.Debug do
    use Annoyer.Channel

    topic "info"
    topic "app_admin_important"

    filter Annoyer.Filter.TextManipulate, prepend: "Hello, ", append: " and World"
    filter Annoyer.Filter.TextManipulate, append: "..."

    outgoing Annoyer.Outgoing.Console
end
