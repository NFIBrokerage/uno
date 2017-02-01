defmodule Uno.External.Event.Game do

  @moduledoc """
  Struct definitions for the events emitted by the Game aggregate.

  The External namespace indicates that these should probably be defined
  in a separate library.
  """

  defmodule GameStarted do
    defstruct [
      :num_players,
      :first_card_in_play,
    ]
  end

  defmodule TurnStarted do
    defstruct [
      :player,
    ]
  end

  defmodule CardPlayed do
    defstruct [
      :player,
      :card,
    ]
  end

  defmodule CardPlayedOutOfTurn do
    defstruct [
      :player,
      :card,
    ]
  end

  defmodule IllegalCardPlayed do
    defstruct [
      :player,
      :card,
    ]
  end

  defmodule InterruptCardPlayed do
    defstruct [
      :player,
      :card,
    ]
  end

  defmodule IllegalInterruptCardPlayed do
    defstruct [
      :player,
      :card,
    ]
  end

end
