defmodule KeyBasedStorage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KeyBasedStorageWeb.Telemetry,
      KeyBasedStorage.Repo,
      {DNSCluster, query: Application.get_env(:key_based_storage, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: KeyBasedStorage.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: KeyBasedStorage.Finch},
      # Start a worker by calling: KeyBasedStorage.Worker.start_link(arg)
      # {KeyBasedStorage.Worker, arg},
      # Start to serve requests, typically the last entry
      KeyBasedStorageWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KeyBasedStorage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KeyBasedStorageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
