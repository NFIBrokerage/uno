defmodule UnoTest do
  use ExUnit.Case
  doctest Uno
  import Uno.Game
  alias Uno.{Command, Event, GameState, Card}

  def build_test_state(events) do
    Enum.reduce(events, GameState.initial, &evolve/2)
  end

  def test_decide(previous_events, command) do
    state = build_test_state(previous_events)
    decide(state, command)
  end

  test "game starts" do
    first_card = %Card.Digit{digit: :three, color: :red}
    command = %Command.StartGame{
      num_players: 4,
      first_card: first_card
    }
    expected_events = [
      %Event.GameStarted{
        num_players: 4,
        first_card: first_card,
      }
    ]
    assert test_decide([], command) == {:ok, expected_events}
  end

  test "cannot start game twice" do
    first_card = %Card.Digit{digit: :three, color: :red}
    game_started = %Event.GameStarted{
      num_players: 4,
      first_card: first_card,
    }
    start_game = %Command.StartGame{
      num_players: 4,
      first_card: first_card
    }
    assert test_decide([game_started], start_game) == {:error, "Cannot start an already started game."}
  end

end
