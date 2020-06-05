defmodule Annoyer do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Annoyer.Http.Fetch,
      {Plug.Cowboy, scheme: :http, plug: Annoyer.Http.RootPlug, options: [port: 8080]},
      Annoyer.Router
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
