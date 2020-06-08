defmodule Annoyer.Channel.CodeislandInline do
  use Annoyer.Channel

  configure(Annoyer.Http.Fetch, topic: "codeisland_inline",
    url: "https://codeisland.org/api/inline.json",
    body_type: :json, json_path: "$.data.*",
    interval: 20 # 20sec
  )

  topic("codeisland_inline")

  def find_ffmpeg(annoyence) do
    any = fn :get, data, next -> Enum.map(data, next) end
    tags = get_in(annoyence.attachments, ["tags", any])
    Enum.all?(tags, fn tag -> tag != "ffmpeg" end)
  end
  transform(Annoyer.Transform.Drop, condition: &__MODULE__.find_ffmpeg/1)

  # todo now, filter all that have already been published...

  outgoing(Annoyer.Outgoing.Console)
end
