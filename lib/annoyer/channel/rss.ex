defmodule Annoyer.Channel.Rss do
  use Annoyer.Channel

  configure(Annoyer.Http.Fetch,
    topic: "rss",
    url: "https://www.reddit.com/r/earthporn/.rss",
    # 20sec
    interval: 20
  )

  topic "rss"

  transform Annoyer.Transform.RssArticles, body_path: [:attachments, :fetch_body]
  transform Annoyer.Transform.ToString, sources: [[:attachments, "rss_entry", :title]]

  outgoing Annoyer.Outgoing.Console, keys: [[:attachments, "rss_entry", :link]]

end
