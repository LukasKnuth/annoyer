defmodule Annoyer.Outgoing.Console do
  @behaviour Annoyer.Outgoing

  @impl true
  def output(_params, annoyence) do
    IO.puts("""
    #{annoyence.topic}: #{annoyence.content}
    -> Meta: #{inspect annoyence.meta}
    -> Attachments: #{inspect annoyence.attachments}
    """)
  end
end
