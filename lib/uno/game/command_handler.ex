defmodule Uno.Game.CommandHandler do
  import Uno.Game.Evolver, only: [build: 1]
  import Uno.Game.Decider, only: [decide: 2]
  alias Uno.Game.State

  @stream "game"

  @doc """
  TODO command contains a game_id used to determine stream
  TODO events fetched in slices
  """
  def handle_command(command, fetch_events, append_events) do
    starting_version = 0
    state =
      @stream
      |> fetch_events.(starting_version)
      |> build
    {:ok, new_events} = decide(command, state)
    after_version = 8 # event version to append after
    append_events.(@stream, new_events, after_version)
  end

end
