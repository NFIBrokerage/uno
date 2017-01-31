defmodule UnoTest do
  use ExUnit.Case
  doctest Uno
  import Uno.Game
  alias Uno.{Command, Event, GameState, Card}

  def given(events) do
    Enum.reduce(events, GameState.initial, &evolve/2)
  end

  def whenn(state, cmd) do
    decide(cmd, state)
  end

  def thenn(actual_events, expected_events) do
    assert actual_events == expected_events
  end

  test "game starts" do
    first_card_in_play = %Card.Digit{digit: :three, color: :red}
    given([])
    |> whenn(
      %Command.StartGame{
        num_players: 4,
        first_card_in_play: first_card_in_play,
      })
    |> thenn(
      {:ok, [
        %Event.GameStarted{
          num_players: 4,
          first_card_in_play: first_card_in_play,
        },
        %Event.TurnStarted{
          player: 0,
        },
      ]})
  end

  test "cannot start game twice" do
    first_card_in_play = %Card.Digit{digit: :three, color: :red}
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: first_card_in_play,
      },
    ])
    |> whenn(
      %Command.StartGame{
        num_players: 4,
        first_card_in_play: first_card_in_play
      })
    |> thenn({:error, "Cannot start an already started game."})
  end

  test "can play card with same color" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 0,
        card: %Card.Digit{digit: :four, color: :red},
      })
    |> thenn(
      {:ok, [
        %Event.CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :four, color: :red},
        },
        %Event.TurnStarted{
          player: 1,
        },
      ]})
  end

  test "can play card with same number" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 0,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %Event.CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :three, color: :green},
        },
        %Event.TurnStarted{
          player: 1,
        },
      ]})
  end

  test "cannot play card that is not the same number or color" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 0,
        card: %Card.Digit{digit: :four, color: :green},
      })
    |> thenn(
      {:ok, [
        %Event.IllegalCardPlayed{
          player: 0,
          card: %Card.Digit{digit: :four, color: :green},
        },
      ]})
  end

  test "next player can play a card" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 0,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %Event.CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :three, color: :green},
        },
        %Event.TurnStarted{
          player: 1,
        },
      ]})
  end

  test "cannot play out of turn" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 3,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %Event.CardPlayedOutOfTurn{
          player: 3,
          card: %Card.Digit{digit: :three, color: :green},
        },
      ]})
  end

  test "identical card can be played out of turn as an interrupt" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 3,
      },
    ])
    |> whenn(
      %Command.PlayInterruptCard{
        player: 3,
        card: %Card.Digit{digit: :three, color: :red},
      })
    |> thenn(
      {:ok, [
        %Event.InterruptCardPlayed{
          player: 3,
          card: %Card.Digit{digit: :three, color: :red},
        },
      ]})
  end

  test "card with different color cannot be played as an interrupt" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayInterruptCard{
        player: 3,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %Event.IllegalInterruptCardPlayed{
          player: 3,
          card: %Card.Digit{digit: :three, color: :green},
        },
      ]})
  end

  test "card with different digit cannot be played as an interrupt" do
    given([
      %Event.GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayInterruptCard{
        player: 3,
        card: %Card.Digit{digit: :four, color: :red},
      })
    |> thenn(
      {:ok, [
        %Event.IllegalInterruptCardPlayed{
          player: 3,
          card: %Card.Digit{digit: :four, color: :red},
        },
      ]})
  end

  test "player turn wraps around" do
    given([
      %Event.GameStarted{
        num_players: 3,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %Event.TurnStarted{
        player: 0,
      },
      %Event.CardPlayed{
        player: 0,
        card: %Card.Digit{digit: :three, color: :green},
      },
      %Event.TurnStarted{
        player: 1,
      },
      %Event.CardPlayed{
        player: 1,
        card: %Card.Digit{digit: :three, color: :green},
      },
      %Event.TurnStarted{
        player: 2,
      },
      %Event.CardPlayed{
        player: 2,
        card: %Card.Digit{digit: :three, color: :green},
      },
      %Event.TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %Command.PlayCard{
        player: 0,
        card: %Card.Digit{digit: :seven, color: :green},
      })
    |> thenn(
      {:ok, [
        %Event.CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :seven, color: :green},
        },
        %Event.TurnStarted{
          player: 1,
        },
      ]})
  end

end
