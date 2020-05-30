defmodule Annoyer.Channel.Debug do
  use Annoyer.Channel

  topic("info")
  topic("app_admin_important")

  # Only works if defined function and reffered like below. In-Line alternative??
  # Anonymous doesnt work since environment is bound on execution.
  def filter_out?(annoyence), do: annoyence.content == "toss"
  filter(Annoyer.Filter.Drop, condition: &__MODULE__.filter_out?/1)

  filter(Annoyer.Filter.TextManipulate, prepend: "Hello, ", append: " and World")
  filter(Annoyer.Filter.TextManipulate, append: "...")

  outgoing(Annoyer.Outgoing.Console)
end
