defmodule ApiChecker.EndpointsTest do
  use ApiChecker.DataCase

  alias ApiChecker.Endpoints

  describe "endpoints" do
    alias ApiChecker.Endpoints.Endpoint

    import ApiChecker.EndpointsFixtures

    @invalid_attrs %{active: nil, name: nil, url: nil, check_interval_seconds: nil, notification_email: nil, notification_slack_webhook: nil}

    test "list_endpoints/0 returns all endpoints" do
      endpoint = endpoint_fixture()
      assert Endpoints.list_endpoints() == [endpoint]
    end

    test "get_endpoint!/1 returns the endpoint with given id" do
      endpoint = endpoint_fixture()
      assert Endpoints.get_endpoint!(endpoint.id) == endpoint
    end

    test "create_endpoint/1 with valid data creates a endpoint" do
      valid_attrs = %{active: true, name: "some name", url: "some url", check_interval_seconds: 42, notification_email: "some notification_email", notification_slack_webhook: "some notification_slack_webhook"}

      assert {:ok, %Endpoint{} = endpoint} = Endpoints.create_endpoint(valid_attrs)
      assert endpoint.active == true
      assert endpoint.name == "some name"
      assert endpoint.url == "some url"
      assert endpoint.check_interval_seconds == 42
      assert endpoint.notification_email == "some notification_email"
      assert endpoint.notification_slack_webhook == "some notification_slack_webhook"
    end

    test "create_endpoint/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Endpoints.create_endpoint(@invalid_attrs)
    end

    test "update_endpoint/2 with valid data updates the endpoint" do
      endpoint = endpoint_fixture()
      update_attrs = %{active: false, name: "some updated name", url: "some updated url", check_interval_seconds: 43, notification_email: "some updated notification_email", notification_slack_webhook: "some updated notification_slack_webhook"}

      assert {:ok, %Endpoint{} = endpoint} = Endpoints.update_endpoint(endpoint, update_attrs)
      assert endpoint.active == false
      assert endpoint.name == "some updated name"
      assert endpoint.url == "some updated url"
      assert endpoint.check_interval_seconds == 43
      assert endpoint.notification_email == "some updated notification_email"
      assert endpoint.notification_slack_webhook == "some updated notification_slack_webhook"
    end

    test "update_endpoint/2 with invalid data returns error changeset" do
      endpoint = endpoint_fixture()
      assert {:error, %Ecto.Changeset{}} = Endpoints.update_endpoint(endpoint, @invalid_attrs)
      assert endpoint == Endpoints.get_endpoint!(endpoint.id)
    end

    test "delete_endpoint/1 deletes the endpoint" do
      endpoint = endpoint_fixture()
      assert {:ok, %Endpoint{}} = Endpoints.delete_endpoint(endpoint)
      assert_raise Ecto.NoResultsError, fn -> Endpoints.get_endpoint!(endpoint.id) end
    end

    test "change_endpoint/1 returns a endpoint changeset" do
      endpoint = endpoint_fixture()
      assert %Ecto.Changeset{} = Endpoints.change_endpoint(endpoint)
    end
  end
end
