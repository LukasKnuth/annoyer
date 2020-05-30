defmodule Annoyer.Http.RootPlug do
  @behaviour Annoyer.Incoming

  use Plug.Router
  require Logger

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)

  @impl Annoyer.Incoming
  def configure(_params) do
    # No additional configuration supported yet.
  end

  @impl Plug
  def init(_options) do
    # todo get the port here?
    Logger.info("Started HTTP Server on :8080")
    {:ok}
  end

  get "/" do
    conn |> put_resp_content_type("text/plain") |> send_resp(200, "Hello from Annoyer")
  end

  # todo message via body
  post "/send/:topic/:message" do
    annoyence = %Annoyer.Annoyence{topic: topic, content: message}

    case Annoyer.Router.process_incoming(annoyence) do
      :ok ->
        conn |> put_resp_content_type("text/plain") |> send_resp(200, "Sent to #{topic}")

      :unknown ->
        conn |> put_resp_content_type("text/plain") |> send_resp(404, "Unknown topic #{topic}")

      _ ->
        conn |> put_resp_content_type("text/plain") |> send_resp(500, "Internal Error")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found!")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
