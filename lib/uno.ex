defmodule Uno do
  use Application

  @event_store Uno.EventStore

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    event_store_settings = Application.get_env :uno, :event_store

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Uno.Worker.start_link(arg1, arg2, arg3)
      # worker(Uno.Worker, [arg1, arg2, arg3]),
      worker(Extreme, [event_store_settings, [name: @event_store]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uno.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
