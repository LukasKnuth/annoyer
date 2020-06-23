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
  defp to_annoyence(config, response) when is_list(response) do
    Enum.map(response, fn res -> to_annoyence(config, res) end)
  end

  defp to_annoyence(%{topic: topic}, response) do
    # todo set content to something useful!
    %Annoyer.Annoyence{
      topic: topic,
      content: "Fetched from asd",
      meta: %{source: "fetch"},
      attachments: response
    }
  end

  @spec fetch(config :: map()) :: {:ok, Annoyence.t() | list(Annoyence.t())} | {:error, any}
  def fetch(%{body_type: :json, path: path} = config) do
    with {:ok, body} <- http_request(config),
         {:ok, parsed} <- Jason.decode(body),
         {:ok, matches} <- ExJSONPath.eval(parsed, path),
         do: {:ok, to_annoyence(config, matches)}
  end

  def fetch(%{body_type: :json} = config) do
    # todo run as above, just without JSON_PATH
  end

  def fetch(%{body_type: :xml, path: path} = config) do
    # todo run GET, XML-path on result
  end

  def fetch(%{body_type: :xml} = config) do
    # todo run GET, without XML-path
  end
end
