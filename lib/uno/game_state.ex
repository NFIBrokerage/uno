defmodule Uno.GameState do
  defstruct [
    :started?,
    :card_in_play,
    :current_player,
  ]

  def initial, do: %Uno.GameState{
    started?: false,
    card_in_play: nil,
    current_player: nil,
  }

end
