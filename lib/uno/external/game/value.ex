defmodule Uno.External.Value.Game do

  @moduledoc """
  Struct definitions for value objects used by the Game aggregate and
  associated commands and events.

  The External namespace indicates that these should probably be defined
  in a separate library.
  """

  defmodule Card.Digit do
    defstruct [
      :digit,
      :color,
    ]
  end

  defmodule Card.Skip do
    defstruct [
      :color,
    ]
  end

  defmodule Card.Kickback do
    defstruct [
      :color,
    ]
  end

end
