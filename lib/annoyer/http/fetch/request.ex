defmodule Annoyer.Http.Fetch.Request do
  alias Annoyer.Annoyence

  @spec http_request(config :: map()) :: {:ok, String.t()} | {:error, any}
  defp http_request(%{url: url}) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code >= 200 and code < 300 ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, %HTTPoison.Error{reason: "Unsuccessful Status code #{code} returned."}}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec to_annoyence(config :: map(), response :: list() | map()) ::
          Annoyence.t() | list(Annoyence.t())
  defp to_annoyence(%{topic: topic, url: url}, body) do
    %Annoyer.Annoyence{
      topic: topic,
      content: "Fetched from #{url}",
      meta: %{source: __MODULE__, source_url: url},
      attachments: %{fetch_body: body}
    }
  end

  @spec fetch(config :: map()) :: {:ok, Annoyence.t()} | {:error, any}
  def fetch(config) do
    with {:ok, body} <- http_request(config),
         do: {:ok, to_annoyence(config, body)}
  end
end
