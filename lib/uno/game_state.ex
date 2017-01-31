defmodule Uno.GameState do
  defstruct [
    :started?,
    :card_in_play,
    :next_player,
  ]

  def initial, do: %Uno.GameState{
    started?: false,
    card_in_play: nil,
    next_player: nil,
  }

end
