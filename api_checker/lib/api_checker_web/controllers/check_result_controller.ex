defmodule ApiCheckerWeb.CheckResultController do
  use ApiCheckerWeb, :controller
  alias ApiChecker.Endpoints

  def index(conn, %{"endpoint_id" => endpoint_id, "limit" => limit}) do
    # Fetch the latest N check results for the endpoint
    results = Endpoints.list_check_results_for_endpoint(endpoint_id, String.to_integer(limit))
    json(conn, %{data: results})
  end

  def index(conn, %{"endpoint_id" => endpoint_id}) do
    # Default to 10 if no limit is provided
    results = Endpoints.list_check_results_for_endpoint(endpoint_id, 10)
    json(conn, %{data: results})
  end
end
