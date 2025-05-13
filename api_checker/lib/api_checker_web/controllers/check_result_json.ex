defmodule ApiCheckerWeb.CheckResultJSON do
  alias ApiChecker.Endpoints.CheckResult

  def index(%{results: results}) do
    %{data: Enum.map(results, &data/1)}
  end

  def data(%CheckResult{} = result) do
    %{
      id: result.id,
      status_code: result.status_code,
      response_time_ms: result.response_time_ms,
      checked_at: result.checked_at,
      endpoint_id: result.endpoint_id
    }
  end
end
