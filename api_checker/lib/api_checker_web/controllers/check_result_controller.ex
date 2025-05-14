defmodule ApiCheckerWeb.CheckResultController do
  use ApiCheckerWeb, :controller
  alias ApiChecker.Endpoints
  require Logger

  def index(conn, %{"endpoint_id" => endpoint_id, "limit" => limit}) do
    Logger.info("CheckResultController.index called with endpoint_id: #{endpoint_id}, limit: #{limit}")
    # Fetch the latest N check results for the endpoint
    results = Endpoints.list_check_results_for_endpoint(endpoint_id, String.to_integer(limit))
    render(conn, ApiCheckerWeb.CheckResultJSON, :index, results: results)
  end

  def index(conn, %{"endpoint_id" => endpoint_id}) do
    Logger.info("CheckResultController.index called with endpoint_id: #{endpoint_id}")
    # Default to 10 if no limit is provided
    results = Endpoints.list_check_results_for_endpoint(endpoint_id, 10)
    render(conn, ApiCheckerWeb.CheckResultJSON, :index, results: results)
  end
end
