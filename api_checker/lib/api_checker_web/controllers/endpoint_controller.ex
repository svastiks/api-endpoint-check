defmodule ApiCheckerWeb.EndpointController do
  use ApiCheckerWeb, :controller
  require Logger
  alias ApiChecker.Endpoints
  alias ApiChecker.Endpoints.Endpoint

  action_fallback ApiCheckerWeb.FallbackController

  plug :load_and_authorize_endpoint when action in [:show, :update, :delete]

  def index(conn, _params) do
    Logger.info("EndpointController.index called")
    user = conn.assigns.current_user
    endpoints = Endpoints.list_endpoints(user)
    render(conn, :index, endpoints: endpoints)
  end

  def create(conn, %{"endpoint" => endpoint_params}) do
    Logger.info("EndpointController.create called with params: #{inspect(endpoint_params)}")
    user = conn.assigns.current_user

    if is_nil(user) do
      Logger.error("EndpointController.create: current_user is nil!")
      # Return an internal server error or unauthorized
      send_resp(conn, :internal_server_error, "User not found") |> halt()
    else
      with {:ok, %Endpoint{} = endpoint} <- Endpoints.create_endpoint(user, endpoint_params) do
        #Notify the checker supervisor about the new endpoint
        GenServer.cast(ApiChecker.CheckerSupervisor, {:endpoint_updated, endpoint})

        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/endpoints/#{endpoint}")
        |> render(:show, endpoint: endpoint)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    Logger.info("EndpointController.show called with id: #{id}")
    user = conn.assigns.current_user
    endpoint = Endpoints.get_endpoint(user, id)
    render(conn, :show, endpoint: endpoint)
  end

  def update(conn, %{"id" => id, "endpoint" => endpoint_params}) do
    Logger.info("EndpointController.update called with id: #{id}, params: #{inspect(endpoint_params)}")
    user = conn.assigns.current_user
    endpoint = Endpoints.get_endpoint(user, id)

    with {:ok, %Endpoint{} = endpoint} <- Endpoints.update_endpoint(endpoint, endpoint_params) do
      # Notify the checker supervisor about the updated endpoint
      updated_endpoint = Endpoints.get_endpoint(user, id)
      GenServer.cast(ApiChecker.CheckerSupervisor, {:endpoint_updated, updated_endpoint})

      conn
      |> render(:show, endpoint: endpoint)
    end
  end

  def delete(conn, %{"id" => id}) do
    Logger.info("EndpointController.delete called with id: #{id}")
    user = conn.assigns.current_user
    endpoint = Endpoints.get_endpoint(user, id)

    with {:ok, %Endpoint{}} <- Endpoints.delete_endpoint(endpoint) do
      # Notify the checker supervisor about the deleted endpoint
      GenServer.cast(ApiChecker.CheckerSupervisor, {:endpoint_deleted, id})

      send_resp(conn, :no_content, "")
    end
  end

  # Plug to load the endpoint and ensure it belongs to the current user
  defp load_and_authorize_endpoint(conn, _) do
    user = conn.assigns.current_user
    endpoint_id = conn.params["id"]

    case Endpoints.get_user_endpoint(user, endpoint_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Endpoint not found"})
        |> halt()
      endpoint ->
        # Assign the loaded endpoint to the connection for use in the action
        assign(conn, :endpoint, endpoint)
    end
  end
end
