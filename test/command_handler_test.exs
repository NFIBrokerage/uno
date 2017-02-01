defmodule Uno.Game.CommandHandlerTest do
  use ExUnit.Case
  import Uno.Game.CommandHandler
  alias Uno.External.Command.Game.{
    PlayCard,
  }
  alias Uno.External.Value.Game.{
    Card,
  }
  alias Uno.External.Event.Game.{
    GameStarted,
    TurnStarted,
    CardPlayed,
  }
  alias Uno.EventStore

  @event_store_proc_name Uno.Extreme.EventStore

  test "command handler fetches and appends events" do
    fetch_events = fn(_stream, _starting_version) ->
      [
        %GameStarted{
          num_players: 4,
          first_card_in_play: %Card.Digit{digit: :three, color: :red},
        },
        %TurnStarted{
          player: 0,
        },
      ]
    end
    command = %PlayCard{
      player: 0,
      card: %Card.Digit{digit: :four, color: :red},
    }
    append_events = fn(stream, events, _after_version) ->
      assert stream == "game"
      assert events == [
        %CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :four, color: :red},
        },
        %TurnStarted{
          player: 1,
        },
      ]
    end
    handle_command(command, fetch_events, append_events)
  end

  test "append to event store" do
    test_stream = "test_game_#{UUID.uuid1}"
    events = [
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ]
    write_events = EventStore.prepare_write_events(test_stream, events)
    {:ok, _response} = Extreme.execute @event_store_proc_name, write_events
  end

  test "fetch from event store" do
    test_stream = "test_game_#{UUID.uuid1}"
    events_to_write = [
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      },
      %TurnStarted{
        player: 0,
      },
    ]
    write_events = EventStore.prepare_write_events(test_stream, events_to_write)
    {:ok, _response} = Extreme.execute @event_store_proc_name, write_events

    {:ok, reader} = Uno.EventStore.StreamSubscriber.start_link(
      @event_store_proc_name,
      test_stream,
      0
    )

    read_events = GenServer.call(reader, :read)
    assert read_events == events_to_write
  end

end
