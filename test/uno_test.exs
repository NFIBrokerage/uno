defmodule UnoTest do
  use ExUnit.Case
  doctest Uno
  import Uno.Game
  alias Uno.{Command, Event, GameState, Card}

  def given(events) do
    Enum.reduce(events, GameState.initial, &evolve/2)
  end

  def whenn(state, cmd) do
    decide(state, cmd)
  end

  def thenn(actual_events, expected_events) do
    assert actual_events == expected_events
  end

  test "game starts" do
    first_card = %Card.Digit{digit: :three, color: :red}
    given([])
    |> whenn(
      %Command.StartGame{
        num_players: 4,
        first_card: first_card,
      })
    |> thenn(
      {:ok, [
        %Event.GameStarted{
          num_players: 4,
          first_card: first_card,
        },
      ]})
  end

  test "cannot start game twice" do
    first_card = %Card.Digit{digit: :three, color: :red}
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card: first_card,
      },
    ])
    |> whenn(
      %Command.StartGame{
        num_players: 4,
        first_card: first_card
      })
    |> thenn({:error, "Cannot start an already started game."})
  end

  test "can play card with same color" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card: %Card.Digit{digit: :three, color: :red},
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 2,
        card: %Card.Digit{digit: :four, color: :red},
      })
    |> thenn(
      {:ok, [
        %Event.CardPlayed{
          player: 2,
          card: %Card.Digit{digit: :four, color: :red},
        },
      ]})
  end

  # test "can play card with same number" do
  #
  # end
  #
  # test "cannot play card that is not the same number or color" do
  #
  # end
  #
  # test "next player can play a card" do
  #
  # end
  #
  # test "non-next player cannot play a card" do
  #
  # end

end
