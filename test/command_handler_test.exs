defmodule Uno.Game.CommandHandlerTest do
  use ExUnit.Case
  import Uno.Game.CommandHandler
  alias Uno.External.Command.Game.{
    StartGame,
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
    fetch_events = fn(_stream, starting_version) ->
      assert starting_version == 0
      {
        [
          %GameStarted{
            num_players: 4,
            first_card_in_play: %Card.Digit{digit: :three, color: :red},
          },
          %TurnStarted{
            player: 0,
          },
        ],
        starting_version + 2
      }
    end
    command = %PlayCard{
      player: 0,
      card: %Card.Digit{digit: :four, color: :red},
    }
    append_events = fn(stream, events, after_version) ->
      assert String.starts_with?(stream, "game")
      assert events == [
        %CardPlayed{
          player: 0,
          card: %Card.Digit{digit: :four, color: :red},
        },
        %TurnStarted{
          player: 1,
        },
      ]
      {:ok, after_version + length(events)}
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
    num_events = 100
    events_to_write = Enum.map(1..num_events, fn(_) ->
      %GameStarted{
        num_players: 4,
        first_card_in_play: %Card.Digit{digit: :three, color: :red},
      }
    end)
    write_events = EventStore.prepare_write_events(test_stream, events_to_write)
    {:ok, response} = Extreme.execute @event_store_proc_name, write_events
    assert response.last_event_number == num_events - 1

    {:ok, reader} = Uno.EventStore.StreamSubscriber.start_link(
      @event_store_proc_name,
      test_stream,
      0
    )

    read_events = GenServer.call(reader, :read)
    assert read_events == {events_to_write, num_events - 1}
  end

  test "fetch events after snapshot version" do
    # restart CommandHandler worker to reset its state
    GenServer.stop(Uno.Game.CommandHandler)
    Process.sleep 10 # wait for worker restart to complete

    first_command = %StartGame{
      num_players: 4,
      first_card_in_play: %Card.Digit{digit: :three, color: :red},
    }
    first_fetch_events = fn(_stream, starting_version) ->
      assert starting_version == 0
      {[], starting_version}
    end
    append_events = fn(_stream, events, after_version) ->
      {:ok, after_version + length(events)}
    end
    handle_command(first_command, first_fetch_events, append_events)

    second_command = %PlayCard{
      player: 0,
      card: %Card.Digit{digit: :four, color: :red},
    }
    second_fetch_events = fn(_stream, starting_version) ->
      assert starting_version == 2
      {
        [
          %GameStarted{
            num_players: 4,
            first_card_in_play: %Card.Digit{digit: :three, color: :red},
          },
          %TurnStarted{
            player: 0,
          },
        ],
        starting_version
      }
    end
    handle_command(second_command, second_fetch_events, append_events)
  end

end
