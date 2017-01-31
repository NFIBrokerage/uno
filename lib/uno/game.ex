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
        first_player: 1,
        first_card_in_play: cmd.first_card_in_play,
      },
    ]}
  end

  def decide(%GameState{} = state, %Command.PlayCard{} = cmd) do
    if cmd.player != state.current_player do
      {:ok, [
        %Event.CardPlayedOutOfTurn{
          player: cmd.player,
          card: cmd.card,
        },
      ]}
    else
      if legal_play?(state.card_in_play, cmd.card) do
        {:ok, [
          %Event.CardPlayed{
            player: cmd.player,
            card: cmd.card,
          },
        ]}
      else
        {:ok, [
          %Event.IllegalCardPlayed{
            player: cmd.player,
            card: cmd.card,
          },
        ]}
      end
    end
  end

  def decide(%GameState{} = state, %Command.PlayInterruptCard{} = cmd) do
    if legal_interrupt_play?(state.card_in_play, cmd.card) do
      {:ok, [
        %Event.InterruptCardPlayed{
          player: cmd.player,
          card: cmd.card,
        },
      ]}
    else
      {:ok, [
        %Event.IllegalInterruptCardPlayed{
          player: cmd.player,
          card: cmd.card,
        },
      ]}
    end
  end

  def legal_play?(card_in_play, played_card) do
    card_in_play.digit == played_card.digit or card_in_play.color == played_card.color
  end

  def legal_interrupt_play?(card_in_play, played_interrupt_card) do
    card_in_play.digit == played_interrupt_card.digit and card_in_play.color == played_interrupt_card.color
  end

  def evolve(%Event.GameStarted{} = event, %GameState{} = state) do
    %{state |
      started?: true,
      card_in_play: event.first_card_in_play,
      current_player: event.first_player,
    }
  end

  def evolve(%Event.CardPlayed{} = event, %GameState{} = state) do
    %{state |
      card_in_play: event.card,
    }
  end

end
