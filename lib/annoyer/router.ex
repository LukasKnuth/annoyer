defmodule Annoyer.Router do
    use GenServer

    # todo Implement with maps NOW, update to ETS after

    @impl true
    def init(_params) do
        channels = case :application.get_key(:annoyer, :modules) do
            {:ok, modules} -> Enum.filter(modules, &is_channel?/1)
            _ -> raise "Couldn't list Apps modules!"
        end

        modules = Enum.reduce(channels, %{}, fn channel, acc ->
           Enum.reduce(channel.__subscribed_topics__, acc, fn topic, routes ->
               Map.update(routes, topic, [channel], &([channel | &1]))
           end)
        end)
        {:ok, modules}
    end

    defp is_channel?(module) do
        Code.ensure_loaded?(module) and function_exported?(module, :__process_channel__, 1)
    end

    @impl true
    def handle_call({:handle, annoyence}, _from, state) do
        topic = annoyence.topic
        case state do
            %{^topic => channels} ->
                Enum.each(channels, fn channel -> channel.__process_channel__(annoyence) end)
                {:reply, :ok, state}
            _ -> {:reply, :unknown, state}
        end
    end

    ### CLIENT CODE

    def start_link(default) do
        GenServer.start_link(__MODULE__, default, name: Annoyer.Router)
    end

    def process_incoming(annoyence) do
        GenServer.call(Annoyer.Router, {:handle, annoyence})
    end

end