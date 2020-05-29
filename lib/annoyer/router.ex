defmodule Annoyer.Router do
    use GenServer

    @impl true
    def init(:ok) do
        {:ok, %{}}
    end

    @impl true
    def handle_call(_request, _from, state) do
        {:reply, :ok, state}
    end

    ### CLIENT CODE

    def start_link(default) do
        GenServer.start_link(__MODULE__, default, name: Annoyer.Router)
    end

    def do_something(pid) do
        GenServer.call(pid, :something)
    end

end