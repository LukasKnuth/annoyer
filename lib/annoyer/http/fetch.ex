defmodule Annoyer.Http.Fetch do
  @behaviour Annoyer.Incoming
  use GenServer
  require Logger
  alias Annoyer.Http.Fetch.Request

  @impl GenServer
  def init(_params) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:config, params}, state) when is_list(params) do
    state = params |> Map.new() |> put_config(state)
    {:noreply, state}
  end

  defp put_config(%{topic: topic, url: url, json_path: path, interval: interval}, state) do
    config = %{topic: topic, url: url, body_type: :json, path: path, interval: interval}
    schedule_interval(config)
    Map.put(state, url, config)
  end

  defp put_config(%{topic: topic, url: url, xml_path: path, interval: interval}, state) do
    config = %{topic: topic, url: url, body_type: :xml, path: path, interval: interval}
    schedule_interval(config)
    Map.put(state, url, config)
  end

  defp put_config(%{topic: topic, url: url, body_type: :json, interval: interval}, state) do
    config = %{topic: topic, url: url, body_type: :json, interval: interval}
    schedule_interval(config)
    Map.put(state, url, config)
  end

  defp put_config(%{topic: topic, url: url, body_type: :xml, interval: interval}, state) do
    config = %{topic: topic, url: url, body_type: :xml, interval: interval}
    schedule_interval(config)
    Map.put(state, url, config)
  end

  defp put_config(_config, state) do
    Logger.info("Invalid config was provided to fetch incoming. Dropped...")
    # Unknown config, ignore
    state
  end

  defp schedule_interval(%{url: state_key, interval: interval_seconds}) do
    Logger.debug("Scheduling fetch of #{state_key} in #{interval_seconds} seconds")
    Process.send_after(self(), {:interval, state_key}, interval_seconds * 1000)
  end

  @impl GenServer
  def handle_info({:interval, key}, state) do
    state =
      case state do
        %{^key => conf} -> process_interval(conf, state)
        _ -> state
      end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_args, state) do
    # handle any unknown messages so we dont crash
    {:noreply, state}
  end

  defp dispatch(annoyence) when is_list(annoyence) do
    Enum.reduce_while(annoyence, :ok, fn a, _acc ->
      case dispatch(a) do
        :ok -> {:cont, :ok}
        :unknown -> {:halt, :unknown}
      end
    end)
  end

  defp dispatch(annoyence) do
    Annoyer.Router.process_incoming(annoyence)
  end

  defp process_interval(%{url: url} = config, state) do
    delivery = with {:ok, responses} <- Request.fetch(config), do: dispatch(responses)

    case delivery do
      :unknown ->
        Logger.info("No consumers for fetch on topic #{config["topic"]}. Dropping it's config...")
        # Nobody cares about this. Remove it.
        Map.delete(state, url)

      # Delivered. Reschedule!
      :ok ->
        schedule_interval(config)
        state

      # Either we we're successful, or there was an error _this time_ and we'd like to retry. todo implement error count and exponential back-off!
      {:error, error} ->
        Logger.error(
          "Error processing fetch on topic #{config["topic"]} for #{url}. Rescheduling...",
          error
        )

        schedule_interval(config)
        state
    end
  end

  ## CLIENT SIDE

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: Annoyer.Http.Fetch)
  end

  @impl Annoyer.Incoming
  def configure(params) do
    GenServer.cast(Annoyer.Http.Fetch, {:config, params})
  end
end
