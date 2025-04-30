defmodule ApiCheckerWeb.EndpointController do
  use ApiCheckerWeb, :controller

  alias ApiChecker.Endpoints
  alias ApiChecker.Endpoints.Endpoint

  action_fallback ApiCheckerWeb.FallbackController

  def index(conn, _params) do
    endpoints = Endpoints.list_endpoints()
    render(conn, :index, endpoints: endpoints)
  end

  def create(conn, %{"endpoint" => endpoint_params}) do
    with {:ok, %Endpoint{} = endpoint} <- Endpoints.create_endpoint(endpoint_params) do

      #Notify the checker supervisor about the new endpoint
      GenServer.cast(ApiChecker.CheckerSupervisor, {:endpoint_updated, endpoint})

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/endpoints/#{endpoint}")
      |> render(:show, endpoint: endpoint)
    end
  end

  def show(conn, %{"id" => id}) do
    endpoint = Endpoints.get_endpoint!(id)
    render(conn, :show, endpoint: endpoint)
  end

  def update(conn, %{"id" => id, "endpoint" => endpoint_params}) do
    endpoint = Endpoints.get_endpoint!(id)

    with {:ok, %Endpoint{} = endpoint} <- Endpoints.update_endpoint(endpoint, endpoint_params) do
      # Notify the checker supervisor about the updated endpoint
      updated_endpoint = Endpoints.get_endpoint!(id)
      GenServer.cast(ApiChecker.CheckerSupervisor, {:endpoint_updated, updated_endpoint})

      conn
      |> render(conn, :show, endpoint: endpoint)
    end
  end

  def delete(conn, %{"id" => id}) do
    endpoint = Endpoints.get_endpoint!(id)

    with {:ok, %Endpoint{}} <- Endpoints.delete_endpoint(endpoint) do
      # Notify the checker supervisor about the deleted endpoint
      GenServer.cast(ApiChecker.CheckerSupervisor, {:endpoint_deleted, id})

      send_resp(conn, :no_content, "")
    end
  end
end
