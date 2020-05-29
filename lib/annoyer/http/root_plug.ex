defmodule Annoyer.Http.RootPlug do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug :match
    plug :dispatch
    plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason

    def init(_options) do
        Logger.info("Started HTTP Server on :8080") # todo get the port here?
        {:ok}
    end

    get "/" do
        conn |> put_resp_content_type("text/plain") |> send_resp(200, "Hello World")
    end

    post "/echo" do
        conn |> send_resp(200, Jason.encode!(conn.body_params)) # TODO doesn't work! Cant encode arbitrary data!
    end

    match _ do
        send_resp(conn, 404, "Not found!")
    end
end