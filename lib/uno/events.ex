defmodule Uno.Event.GameStarted do
  defstruct [
    :num_players,
    :first_card,
    :draw_pile, # [%Card]
    :first_player, # player_number:
  ]
end

defmodule Uno.Event.CardPlayed do
  defstruct [
    :player_number,
    :card,
  ]
end
