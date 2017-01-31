defmodule Uno.Game do
  alias Uno.{Command, Event, GameState}

  @moduledoc """

  color -> :red, :green, :blue, :yellow
  digit -> :zero, :one, :two, ..., :nine

  card -> {:digit, :color} | {:skip, :color} | {:kickback, :color} |

  """

  def decide(%GameState{started?: true}, %Command.StartGame{} = cmd) do
    {:error, "Cannot start an already started game."}
  end
  def decide(%GameState{} = state, %Command.StartGame{} = cmd) do
    events = [
      %Event.GameStarted{
        num_players: cmd.num_players,
        first_card: cmd.first_card,
        #draw_pile: [], # shuffled list of remaining cards
      }
    ]
    {:ok, events}
  end


  def evolve(%GameState{} = state, %Event.GameStarted{} = event) do
    %{state | started?: true}
  end

end
