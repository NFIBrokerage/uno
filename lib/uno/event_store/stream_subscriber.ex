defmodule Uno.EventStore.StreamSubscriber do
  use GenServer
  require Logger

  def start_link(extreme, stream, last_processed_event) do
    GenServer.start_link __MODULE__, {extreme, stream, last_processed_event}
  end

  def init({extreme, stream, last_processed_event}) do
    state = %{
      event_store: extreme,
      subscription_ref: nil,
      stream: stream,
      # last_event: last_processed_event,
    }
    GenServer.cast self, :subscribe
    {:ok, state}
  end

  def handle_cast(:subscribe, state) do
    # read only unprocessed events and stay subscribed
    {:ok, subscription} = Extreme.read_and_stay_subscribed state.event_store, self, state.stream, 0
    # we want to monitor when subscription is crashed so we can resubscribe
    ref = Process.monitor subscription
    {:noreply, %{state | subscription_ref: ref}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{subscription_ref: ref} = state) do
    GenServer.cast self, :subscribe
    {:noreply, state}
  end

  def handle_info({:on_event, push}, state) do
    push.event.data
    |> :erlang.binary_to_term
    |> process_event
    # event_number = push.link.event_number
    # :ok = update_last_event state.stream, event_number
    # {:noreply, %{state | last_event: event_number}}
    {:noreply, state}
  end

  def handle_info(:caught_up, state) do
    Logger.debug "We are up to date!"
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp process_event(event), do: IO.puts("Do something with #{inspect event}")
  defp update_last_event(_stream, _event_number), do: IO.puts("Persist last processed event_number for stream")

end
