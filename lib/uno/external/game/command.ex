defmodule Uno.External.Command.Game do

  @moduledoc """
  Struct definitions for the commands that can be issued to the Game
  aggregate.

  The External namespace indicates that these should probably be defined
  in a separate library.
  """

  defmodule StartGame do
    defstruct [
      :num_players,
      :first_card_in_play,
    ]
  end

  defmodule PlayCard do
    defstruct [
      :player,
      :card,
    ]
  end

  defmodule PlayInterruptCard do
    defstruct [
      :player,
      :card,
    ]
  end

end
