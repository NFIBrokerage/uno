defmodule Uno do
  use Application

  @event_store_proc_name Uno.Extreme.EventStore

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    event_store_settings = Application.get_env :uno, :event_store

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Uno.Worker.start_link(arg1, arg2, arg3)
      # worker(Uno.Worker, [arg1, arg2, arg3]),
      worker(Extreme, [event_store_settings, [name: @event_store_proc_name]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uno.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def doo(command) do
    Uno.Game.CommandHandler.handle_command(
      command,
      &fetch_events_from_event_store/2,
      &append_events_to_event_store/3)
  end

  defp fetch_events_from_event_store(stream, starting_version) do
    {:ok, reader} = Uno.EventStore.StreamSubscriber.start_link(
      @event_store_proc_name,
      stream,
      starting_version)
    GenServer.call(reader, :read)
  end

  defp append_events_to_event_store(stream, events, after_version) do
    write_events = Uno.EventStore.prepare_write_events(stream, events)
    {:ok, _response} = Extreme.execute(@event_store_proc_name, write_events)
  end

end
