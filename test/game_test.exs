defmodule Uno.GameTest do
  use ExUnit.Case
  import Uno.{Game.Decider, Game.Evolver}
  alias Uno.External.Command.Game.{
    StartGame,
    PlayCard,
    PlayInterruptCard,
  }
  alias Uno.Game.State
  alias Uno.External.Value.Game.{
    Card,
  }
  alias Uno.External.Event.Game.{
    GameStarted,
    TurnStarted,
    CardPlayed,
    CardPlayedOutOfTurn,
    IllegalCardPlayed,
    InterruptCardPlayed,
    IllegalInterruptCardPlayed,
  }


  def given(events) do
    Enum.reduce(events, State.initial, &evolve/2)
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
      %StartGame{
        num_players: 4,
        first_card_in_play: first_card_in_play,
      })
    |> thenn(
      {:ok, [
        %GameStarted{
          num_players: 4,
          first_card_in_play: first_card_in_play,
        },
        %TurnStarted{
          player: 0,
        },
      ]})
  end

  test "cannot start game twice" do
    first_card_in_play = %Card.Digit{digit: :three, color: :red}
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: first_card_in_play,
      },
    ])
    |> whenn(
      %StartGame{
        num_players: 4,
        first_card_in_play: first_card_in_play
      })
    |> thenn({:error, "Cannot start an already started game."})
  end

  test "can play card with same color" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayCard{
        player: 0,
        card: %Card.Digit{digit: :four, color: :red},
      })
    |> thenn(
      {:ok, [
        %CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :four, color: :red},
        },
        %TurnStarted{
          player: 1,
        },
      ]})
  end

  test "can play card with same number" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayCard{
        player: 0,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :three, color: :green},
        },
        %TurnStarted{
          player: 1,
        },
      ]})
  end

  test "cannot play card that is not the same number or color" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayCard{
        player: 0,
        card: %Card.Digit{digit: :four, color: :green},
      })
    |> thenn(
      {:ok, [
        %IllegalCardPlayed{
          player: 0,
          card: %Card.Digit{digit: :four, color: :green},
        },
      ]})
  end

  test "next player can play a card" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayCard{
        player: 0,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :three, color: :green},
        },
        %TurnStarted{
          player: 1,
        },
      ]})
  end

  test "cannot play out of turn" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayCard{
        player: 3,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %CardPlayedOutOfTurn{
          player: 3,
          card: %Card.Digit{digit: :three, color: :green},
        },
      ]})
  end

  test "identical card can be played out of turn as an interrupt" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 3,
      },
    ])
    |> whenn(
      %PlayInterruptCard{
        player: 3,
        card: %Card.Digit{digit: :three, color: :red},
      })
    |> thenn(
      {:ok, [
        %InterruptCardPlayed{
          player: 3,
          card: %Card.Digit{digit: :three, color: :red},
        },
      ]})
  end

  test "card with different color cannot be played as an interrupt" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayInterruptCard{
        player: 3,
        card: %Card.Digit{digit: :three, color: :green},
      })
    |> thenn(
      {:ok, [
        %IllegalInterruptCardPlayed{
          player: 3,
          card: %Card.Digit{digit: :three, color: :green},
        },
      ]})
  end

  test "card with different digit cannot be played as an interrupt" do
    given([
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayInterruptCard{
        player: 3,
        card: %Card.Digit{digit: :four, color: :red},
      })
    |> thenn(
      {:ok, [
        %IllegalInterruptCardPlayed{
          player: 3,
          card: %Card.Digit{digit: :four, color: :red},
        },
      ]})
  end

  test "player turn wraps around" do
    given([
      %GameStarted{
        num_players: 3,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
      %CardPlayed{
        player: 0,
        card: %Card.Digit{digit: :three, color: :green},
      },
      %TurnStarted{
        player: 1,
      },
      %CardPlayed{
        player: 1,
        card: %Card.Digit{digit: :three, color: :green},
      },
      %TurnStarted{
        player: 2,
      },
      %CardPlayed{
        player: 2,
        card: %Card.Digit{digit: :three, color: :green},
      },
      %TurnStarted{
        player: 0,
      },
    ])
    |> whenn(
      %PlayCard{
        player: 0,
        card: %Card.Digit{digit: :seven, color: :green},
      })
    |> thenn(
      {:ok, [
        %CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :seven, color: :green},
        },
        %TurnStarted{
          player: 1,
        },
      ]})
  end

end
