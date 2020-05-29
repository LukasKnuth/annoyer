defmodule Annoyer do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Annoyer.Router,
      {Plug.Cowboy, scheme: :http, plug: Annoyer.Http.RootPlug, options: [port: 8080]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
