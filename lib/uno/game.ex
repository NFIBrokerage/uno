defmodule Uno.Game do
  alias Uno.{Command, Event, GameState}

  @moduledoc """

  color -> :red, :green, :blue, :yellow
  digit -> :zero, :one, :two, ..., :nine

  card -> {:digit, :color} | {:skip, :color} | {:kickback, :color} |

  """

  def decide(%GameState{} = state, %Command.StartGame{} = start_game) do
    [
      %Event.GameStarted{
        num_players: start_game.num_players,
        first_card: start_game.first_card,
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
