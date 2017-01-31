defmodule Uno.GameState do
  defstruct [
    :started?,
  ]

  def initial, do: %Uno.GameState{
    started?: false,
  }

end
