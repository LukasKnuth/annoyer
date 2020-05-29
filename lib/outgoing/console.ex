defmodule Annoyer.Outgoing.Console do

  def output(_params, annoyence) do
    IO.puts "#{annoyence.topic}: #{annoyence.content}"
  end

end