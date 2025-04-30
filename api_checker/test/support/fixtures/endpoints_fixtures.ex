defmodule ApiChecker.EndpointsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ApiChecker.Endpoints` context.
  """

  @doc """
  Generate a endpoint.
  """
  def endpoint_fixture(attrs \\ %{}) do
    {:ok, endpoint} =
      attrs
      |> Enum.into(%{
        active: true,
        check_interval_seconds: 42,
        name: "some name",
        notification_email: "some notification_email",
        notification_slack_webhook: "some notification_slack_webhook",
        url: "some url"
      })
      |> ApiChecker.Endpoints.create_endpoint()

    endpoint
  end
end
