defmodule UnoTest do
  use ExUnit.Case
  doctest Uno
  import Uno.Game
  alias Uno.{Command, Event, GameState, Card}

  test "simplest model" do
    initial_state = GameState.initial
    command = %{}

    assert decide(initial_state, command) == []

    event = %{}
    assert evolve(initial_state, event) == initial_state
    assert initial_state |> evolve(event) |> evolve(event) == initial_state
    # external monoid

  end

  test "start game" do
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
    assert decide(GameState.initial, command) == expected_events
  end
end
