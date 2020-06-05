defmodule Annoyer.Http.Fetch do
    @behaviour Annoyer.Incoming
    use GenServer

    @impl GenServer
    def init(_params) do
        
    end

    ## CLIENT SIDE

    def start_link(default) do
        GenServer.start_link(__MODULE__, default, name: Annoyer.Http.Fetch)
    end

    @impl Annoyer.Incoming
    def configure(params) do
        # todo actually configure stuff here!
        IO.puts inspect params
    end
end