defmodule UnoTest do
  use ExUnit.Case
  doctest Uno
  import Uno.Game
  alias Uno.{Command, Event, GameState, Card}

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
    assert decide(GameState.initial, command) == {:ok, expected_events}
  end

  test "cannot start game twice" do
    first_card = %Card.Digit{digit: :three, color: :red}
    game_started = %Event.GameStarted{
      num_players: 4,
      first_card: first_card,
    }
    state = evolve(GameState.initial, game_started)
    start_game = %Command.StartGame{
      num_players: 4,
      first_card: first_card
    }
    assert decide(state, start_game) == {:error, "Cannot start an already started game."}
  end

end
