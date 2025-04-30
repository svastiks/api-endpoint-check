defmodule ApiCheckerWeb.EndpointControllerTest do
  use ApiCheckerWeb.ConnCase

  import ApiChecker.EndpointsFixtures

  alias ApiChecker.Endpoints.Endpoint

  @create_attrs %{
    active: true,
    name: "some name",
    url: "some url",
    check_interval_seconds: 42,
    notification_email: "some notification_email",
    notification_slack_webhook: "some notification_slack_webhook"
  }
  @update_attrs %{
    active: false,
    name: "some updated name",
    url: "some updated url",
    check_interval_seconds: 43,
    notification_email: "some updated notification_email",
    notification_slack_webhook: "some updated notification_slack_webhook"
  }
  @invalid_attrs %{active: nil, name: nil, url: nil, check_interval_seconds: nil, notification_email: nil, notification_slack_webhook: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all endpoints", %{conn: conn} do
      conn = get(conn, ~p"/api/endpoints")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create endpoint" do
    test "renders endpoint when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/endpoints", endpoint: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/endpoints/#{id}")

      assert %{
               "id" => ^id,
               "active" => true,
               "check_interval_seconds" => 42,
               "name" => "some name",
               "notification_email" => "some notification_email",
               "notification_slack_webhook" => "some notification_slack_webhook",
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/endpoints", endpoint: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update endpoint" do
    setup [:create_endpoint]

    test "renders endpoint when data is valid", %{conn: conn, endpoint: %Endpoint{id: id} = endpoint} do
      conn = put(conn, ~p"/api/endpoints/#{endpoint}", endpoint: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/endpoints/#{id}")

      assert %{
               "id" => ^id,
               "active" => false,
               "check_interval_seconds" => 43,
               "name" => "some updated name",
               "notification_email" => "some updated notification_email",
               "notification_slack_webhook" => "some updated notification_slack_webhook",
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, endpoint: endpoint} do
      conn = put(conn, ~p"/api/endpoints/#{endpoint}", endpoint: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete endpoint" do
    setup [:create_endpoint]

    test "deletes chosen endpoint", %{conn: conn, endpoint: endpoint} do
      conn = delete(conn, ~p"/api/endpoints/#{endpoint}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/endpoints/#{endpoint}")
      end
    end
  end

  defp create_endpoint(_) do
    endpoint = endpoint_fixture()
    %{endpoint: endpoint}
  end
end
