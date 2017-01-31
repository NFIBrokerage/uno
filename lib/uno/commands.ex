alias Uno.Command

defmodule Command.StartGame do
  defstruct [
    :num_players,
    :first_card,
  ]
end
