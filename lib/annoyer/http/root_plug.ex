defmodule Annoyer.Http.RootPlug do
    use Plug.Router
    require Logger

    if Mix.env == :dev do
        use Plug.Debugger
    end
    use Plug.ErrorHandler

    plug Plug.Logger
    plug :match
    plug :dispatch
    plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason

    def init(_options) do
        Logger.info("Started HTTP Server on :8080") # todo get the port here?
        {:ok}
    end

    get "/" do
        conn |> put_resp_content_type("text/plain") |> send_resp(200, "Hello from Annoyer")
    end

    post "/send/:topic" do
        conn |> put_resp_content_type("text/plain") |> send_resp(200, "To channel #{topic}")
    end

    match _ do
        send_resp(conn, 404, "Not found!")
    end

    defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
        send_resp(conn, conn.status, "Something went wrong")
    end
end