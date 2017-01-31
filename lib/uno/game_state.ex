defmodule Uno.GameState do
  defstruct [
    :started?,
    :card_in_play,
  ]

  def initial, do: %Uno.GameState{
    started?: false,
    card_in_play: nil,
  }

end
