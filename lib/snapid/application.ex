defmodule Snapid.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SnapidWeb.Telemetry,
      Snapid.Repo,
      {DNSCluster, query: Application.get_env(:snapid, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Snapid.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Snapid.Finch},
      # Start a worker by calling: Snapid.Worker.start_link(arg)
      # {Snapid.Worker, arg},
      # Start to serve requests, typically the last entry
      SnapidWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Snapid.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SnapidWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
