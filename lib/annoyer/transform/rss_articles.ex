defmodule Annoyer.Transform.RssArticles do
  @behaviour Annoyer.Transform
  alias Annoyer.Helpers.Path
  import Meeseeks.XPath

  @impl true
  def transform(params, annoyence) when is_list(params) do
    params |> Map.new |> do_transform(annoyence)
  end

  defp do_transform(%{body_path: body_path}, annoyence) do
    result = with {:ok, body} <- Path.fetch(body_path, annoyence),
                  {:ok, parsed} <- parse_xml(body),
                  do: split_to_attachments(parsed)

    case result do
      :error -> :drop
      [] -> :drop
      attachments ->
        annoyences =
          attachments
          |> Enum.filter(&map_size(&1) > 0)
          |> Enum.map(&Path.put([:attachments, "rss_entry"], annoyence, &1))
        {:ok, annoyences}
    end
  end

  defp parse_xml(body) do
    case Meeseeks.parse(body, :xml) do
      {:error, _} = err -> err
      parsed -> {:ok, parsed}
    end
  end

  defp split_to_attachments(body) do
    Meeseeks.all(body, xpath("//entry"))
    |> Enum.map(&entry_to_attachment(&1))
  end

  defp entry_to_attachment(entry) do
    title = Meeseeks.one(entry, xpath("//title")) |> Meeseeks.text()
    author = Meeseeks.one(entry, xpath("//author//name")) |> Meeseeks.text()
    link = Meeseeks.one(entry, xpath("//link")) |> Meeseeks.attr("href")
    date = Meeseeks.one(entry, xpath("//updated")) |> Meeseeks.text() |> to_datetime

    %{title: title, author: author, link: link, date: date}
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  defp to_datetime(nil), do: nil
  defp to_datetime(text) do
    case DateTime.from_iso8601(text) do
      {:ok, date, _} -> date
      _ -> nil
    end
  end
end
