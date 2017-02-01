defmodule Uno.EventStore do
  alias Extreme.Messages, as: ExMsg

  def prepare_write_events(stream, events) do
    wrapped_events = Enum.map(events, fn event ->
      ExMsg.NewEvent.new(
        event_id: Extreme.Tools.gen_uuid(),
        event_type: to_string(event.__struct__),
        data_content_type: 0,
        metadata_content_type: 0,
        data: :erlang.term_to_binary(event),
        metadata: ""
      ) end)
    ExMsg.WriteEvents.new(
      event_stream_id: stream,
      expected_version: -2,
      events: wrapped_events,
      require_master: false
    )
  end

end
