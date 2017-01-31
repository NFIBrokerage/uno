defmodule Uno.Game do
  alias Uno.{Command, Event, GameState}

  @moduledoc """

  color -> :red, :green, :blue, :yellow
  digit -> :zero, :one, :two, ..., :nine

  card -> {:digit, :color} | {:skip, :color} | {:kickback, :color} |

  """

  def decide(%GameState{} = state, %Command.StartGame{} = cmd) do
    [
      %Event.GameStarted{
        num_players: cmd.num_players,
        first_card: cmd.first_card,
      }
    ]
  end

  def decide(%GameState{} = state, command) do
    []
  end

  def evolve(%GameState{} = state, event) do
    state
  end

end
