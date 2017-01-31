alias Uno.Event

defmodule Event.GameStarted do
  defstruct [
    :num_players,
    :first_card_in_play,
  ]
end

defmodule Event.TurnStarted do
  defstruct [
    :player,
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
