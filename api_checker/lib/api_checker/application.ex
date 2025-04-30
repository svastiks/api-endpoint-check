defmodule ApiChecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ApiChecker.Repo,
      # Start Finch
      {Finch, name: ApiChecker.Finch},

      # Start the Checker Supervisor
      ApiChecker.CheckerSupervisor,

      # Start to serve requests, typically the last entry
      ApiCheckerWeb.Endpoint
      # ApiCheckerWeb.Telemetry, # Removed for API-only backend
      # {DNSCluster, query: Application.get_env(:api_checker, :dns_cluster_query) || :ignore}, # Removed
      # {Phoenix.PubSub, name: ApiChecker.PubSub}, # Removed
      # Start a worker by calling: ApiChecker.Worker.start_link(arg)
      # {ApiChecker.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ApiChecker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ApiCheckerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
