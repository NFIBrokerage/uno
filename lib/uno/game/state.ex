defmodule Uno.Game.State do
  defstruct [
    :started?,
    :card_in_play,
    :current_player,
    :num_players,
  ]

  def initial, do: %Uno.Game.State{
    started?: false,
    card_in_play: nil,
    current_player: nil,
    num_players: nil,
  }

end
