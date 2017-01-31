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
    {:ok, [
      %Event.GameStarted{
        num_players: cmd.num_players,
        first_card: cmd.first_card,
      },
    ]}
  end

  def decide(%GameState{} = state, %Command.PlayCard{} = cmd) do
    {:ok, [
      %Event.CardPlayed{
        player: cmd.player,
        card: cmd.card,
      },
    ]}
  end


  def evolve(%Event.GameStarted{} = event, %GameState{} = state) do
    %{state |
      started?: true,
      card_in_play: event.first_card,
    }
  end

end
