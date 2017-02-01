defmodule Uno.Game.CommandHandler do
  use GenServer
  import Uno.Game.Evolver, only: [evolve: 2]
  import Uno.Game.Decider, only: [decide: 2]
  alias Uno.Game.State
  require Logger

  @stream "game_b4a59afe-5535-4b92-934b-7624b0751e14"

  def start_link() do
    Logger.debug("starting CommandHandler for aggregate stream #{@stream}")
    initial_state = %{game_snapshot: State.initial, game_snapshot_version: 0}
    # TODO load initial game state from event store
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @doc """
  TODO command contains a game_id used to determine stream
  TODO events fetched in slices
  """
  def handle_command(command, fetch_events, append_events) do
    {new_events, new_version} = GenServer.call(__MODULE__, {:handle_command, command, fetch_events, append_events})
  end

  def handle_call({:handle_command, command, fetch_events, append_events}, _from, state) do
    %{game_snapshot: snapshot, game_snapshot_version: snapshot_version} = state
    {fetched_events, last_fetched_event_number} = fetch_events.(@stream, snapshot_version)
    updated_game = build(fetched_events, snapshot)
    {:ok, new_events} = decide(command, updated_game)
    {:ok, new_version} = append_events.(@stream, new_events, last_fetched_event_number)
    new_game = build(new_events, updated_game)
    new_state = %{state | game_snapshot: new_game, game_snapshot_version: new_version}
    {:reply, {:ok, {new_events, new_version}}, new_state}
  end

  def build(events, %State{} = state \\ State.initial) do
    Enum.reduce(events, state, &evolve/2)
  end

end
