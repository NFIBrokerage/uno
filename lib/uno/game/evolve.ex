defmodule Uno.Game.Evolver do
  alias Uno.External.Event.Game.{
    GameStarted,
    TurnStarted,
    CardPlayed,
  }
  alias Uno.Game.State

  def evolve(%GameStarted{} = event, %State{} = state) do
    %{state |
      started?: true,
      num_players: event.num_players,
      card_in_play: event.first_card_in_play,
    }
  end

  def evolve(%TurnStarted{} = event, %State{} = state) do
    %{state |
      current_player: event.player,
    }
  end

  def evolve(%CardPlayed{} = event, %State{} = state) do
    %{state |
      card_in_play: event.card,
    }
  end

end
