defmodule Annoyer.Channel.CodeislandInline do
  use Annoyer.Channel
  alias Annoyer.Helpers.Path

  configure(Annoyer.Http.Fetch,
    topic: "codeisland_inline",
    url: "https://codeisland.org/api/inline.json",
    interval: 10
  )

  topic "codeisland_inline"

  transform Annoyer.Transform.JsonParser, body_path: [:attachments, :fetch_body], json_path: "$.data.*"

  def find_ffmpeg(annoyence) do
    Path.get([:attachments, "json", "tags"], annoyence, [])
    |> Enum.all?(fn tag -> tag != "ffmpeg" end)
  end
  transform Annoyer.Transform.Drop, condition: &__MODULE__.find_ffmpeg/1

  # todo now, filter all that have already been published...

  transform Annoyer.Transform.ToString, sources: [[:attachments, "json", "title"], [:attachments, "json", "url"]], join: " -> "

  outgoing Annoyer.Outgoing.Console, keys: [[:attachments, "json", "tags"], [:meta, :source_url]]
end
