defmodule Uno.Event.GameStarted do
  defstruct [
    :num_players,
    :first_card_in_play,
    :first_player, # player_number:
  ]
end

defmodule Uno.Event.CardPlayed do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Uno.Event.IllegalCardPlayed do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Uno.Event.InterruptCardPlayed do
  defstruct [
    :player,
    :card,
  ]
end

defmodule Uno.Event.IllegalInterruptCardPlayed do
  defstruct [
    :player,
    :card,
  ]
end
