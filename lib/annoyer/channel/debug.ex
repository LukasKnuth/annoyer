defmodule Annoyer.Channel.Debug do
  use Annoyer.Channel

  topic("info")
  topic("app_admin_important")

  # Only works if defined function and reffered like below. In-Line alternative??
  # Anonymous doesnt work since environment is bound on execution.
  def filter_out?(annoyence), do: annoyence.content == "toss"
  transform(Annoyer.Transform.Drop, condition: &__MODULE__.filter_out?/1)

  transform(Annoyer.Transform.TextManipulate, prepend: "Hello, ", append: " and World")
  transform(Annoyer.Transform.TextManipulate, append: "...")

  outgoing(Annoyer.Outgoing.Console)
end
