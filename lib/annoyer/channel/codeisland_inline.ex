defmodule Annoyer.Channel.CodeislandInline do
  use Annoyer.Channel

  configure(Annoyer.Http.Fetch, topic: "codeisland_inline",
    url: "https://codeisland.org/api/inline.json",
    body_type: :json, json_path: "$.data..title",
    interval: 20 # 20sec
  )

  topic("codeisland_inline")

  outgoing(Annoyer.Outgoing.Console)
end
