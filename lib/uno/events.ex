alias Uno.Event

defmodule Event.GameStarted do
  defstruct [
    :num_players,
    :first_card_in_play,
    :first_player, # player_number:
  ]
end

defmodule Event.CardPlayed do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Event.CardPlayedOutOfTurn do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Event.IllegalCardPlayed do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Event.InterruptCardPlayed do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Event.IllegalInterruptCardPlayed do
  defstruct [
    :player,
    :card,
  ]
end
