defmodule Annoyer.Channel.CodeislandInline do
  use Annoyer.Channel

  configure(Annoyer.Http.Fetch,
    topic: "codeisland_inline",
    url: "https://codeisland.org/api/inline.json",
    interval: 10
  )

  topic "codeisland_inline"

  transform Annoyer.Transform.JsonParser, body_path: [:attachments, :fetch_body], json_path: "$.data.*"

  def find_ffmpeg(annoyence) do
    any = fn :get, data, next -> Enum.map(data, next) end
    tags = get_in(annoyence.attachments, [:json, "tags", any])
    Enum.all?(tags, fn tag -> tag != "ffmpeg" end)
  end
  transform Annoyer.Transform.Drop, condition: &__MODULE__.find_ffmpeg/1

  # todo now, filter all that have already been published...

  outgoing Annoyer.Outgoing.Console, keys: [[:attachments, :json, "title"], [:attachments, :json, "tags"], [:meta, :source_url]]
end
