alias Uno.Command

defmodule Command.StartGame do
  defstruct [
    :num_players,
    :first_card_in_play,
  ]
end

defmodule Command.PlayCard do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Command.PlayInterruptCard do
  defstruct [
    :player,
    :card,
  ]
end
