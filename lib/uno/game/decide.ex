defmodule Uno.Game.Decider do
  alias Uno.External.Command.Game.{
    StartGame,
    PlayCard,
    PlayInterruptCard,
  }
  alias Uno.Game.State
  alias Uno.External.Event.Game.{
    GameStarted,
    TurnStarted,
    CardPlayed,
    CardPlayedOutOfTurn,
    IllegalCardPlayed,
    InterruptCardPlayed,
    IllegalInterruptCardPlayed,
  }

  @moduledoc """

  color -> :red, :green, :blue, :yellow
  digit -> :zero, :one, :two, ..., :nine

  card -> {:digit, :color} | {:skip, :color} | {:kickback, :color} |

  """

  def decide(%StartGame{} = cmd, %State{} = state) do
    if (state.started?) do
      {:error, "Cannot start an already started game."}
    else
      {:ok, [
        %GameStarted{
          num_players: cmd.num_players,
          first_card_in_play: cmd.first_card_in_play,
        },
        %TurnStarted{
          player: 0
        },
      ]}
    end
  end

  def decide(%PlayCard{} = cmd, %State{} = state) do
    if cmd.player != state.current_player do
      {:ok, [
        %CardPlayedOutOfTurn{
          player: cmd.player,
          card: cmd.card,
        },
      ]}
    else
      if legal_play?(state.card_in_play, cmd.card) do
        {:ok, [
          %CardPlayed{
            player: cmd.player,
            card: cmd.card,
          },
          %TurnStarted{
            player: next_player(state.current_player, state.num_players),
          },
        ]}
      else
        {:ok, [
          %IllegalCardPlayed{
            player: cmd.player,
            card: cmd.card,
          },
        ]}
      end
    end
  end

  def decide(%PlayInterruptCard{} = cmd, %State{} = state) do
    if legal_interrupt_play?(state.card_in_play, cmd.card) do
      {:ok, [
        %InterruptCardPlayed{
          player: cmd.player,
          card: cmd.card,
        },
        # House Rule: when an interrupt is played, the turn moves to the left
        # of the interrupter. Add a TurnStarted event here.
      ]}
    else
      {:ok, [
        %IllegalInterruptCardPlayed{
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

  def next_player(current_player, num_players) do
    (current_player + 1) |> rem(num_players)
  end

end
