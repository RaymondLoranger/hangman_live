defmodule Hangman.Live.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hangman.LiveWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:hangman_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hangman.Live.PubSub},
      # Start a worker by calling: Hangman.Live.Worker.start_link(arg)
      # {Hangman.Live.Worker, arg},
      # Start to serve requests, typically the last entry
      Hangman.LiveWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hangman.Live.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Hangman.LiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
