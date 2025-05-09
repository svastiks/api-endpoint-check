defmodule ApiCheckerWeb.EndpointJSON do
  alias ApiChecker.Endpoints.Endpoint

  @doc """
  Renders a list of endpoints.
  """
  def index(%{endpoints: endpoints}) do
    %{data: for(endpoint <- endpoints, do: data(endpoint))}
  end

  @doc """
  Renders a single endpoint.
  """
  def show(%{endpoint: endpoint}) do
    %{data: data(endpoint)}
  end

  defp data(%Endpoint{} = endpoint) do
    %{
      id: endpoint.id,
      url: endpoint.url,
      check_interval_seconds: endpoint.check_interval_seconds,
      active: endpoint.active,
      name: endpoint.name,
      notification_email: endpoint.notification_email,
      notification_slack_webhook: endpoint.notification_slack_webhook
    }
  end

  def show(%{endpoint: endpoint}) do
    %{data: endpoint}
  end

  def index(%{endpoints: endpoints}) do
    %{data: endpoints}
  end
end
