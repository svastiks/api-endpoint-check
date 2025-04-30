defmodule ApiChecker.Checker do
  @moduledoc """
  Handles making HTTP requests to API endpoints and recording the results.
  """

  alias ApiChecker.Endpoints.Endpoint
  alias ApiChecker.Endpoints.CheckResult
  alias ApiChecker.Repo
  alias ApiChecker.Notifier
  import Ecto.Query, warn: false
  require Logger

  # Timeout for HTTP requests
  @request_timeout 15_000 # 15 seconds

  @doc """
  Performs an HTTP GET check on an endpoint and records the result.
  """
  def check_and_record(endpoint = %Endpoint{}) do
    Logger.info("Checking endpoint: #{endpoint.url}")

    start_time = System.monotonic_time()

    case Finch.build(:get, endpoint.url)
         |> Finch.request(ApiChecker.Finch, receive_timeout: @request_timeout) do
      {:ok, %Finch.Response{status: status_code, body: _body}} ->
        end_time = System.monotonic_time()
        response_time_ms = System.convert_time_unit(end_time - start_time, :native, :millisecond)

        Logger.info("Check successful for #{endpoint.url}: Status #{status_code}, Time #{response_time_ms}ms")

        error_message = if status_code >= 300, do: "HTTP Error: #{status_code}", else: nil
        result = %CheckResult{
          endpoint_id: endpoint.id,
          status_code: status_code,
          response_time_ms: response_time_ms,
          success: status_code >= 200 and status_code < 300,
          error_message: error_message,
          checked_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
        }

        # Send notification for non-200 status codes
        if status_code >= 300 do
          Logger.info("Attempting to send notification for non-200 status code #{status_code} for #{endpoint.url}")
          if endpoint.notification_email do
            Logger.info("Endpoint has notification email configured: #{endpoint.notification_email}")
            Notifier.notify(endpoint, "Check returned status code #{status_code} for #{endpoint.url}")
          else
            Logger.info("No notification email configured for endpoint #{endpoint.url}")
          end
        end

        Repo.insert(result)

      {:error, %Finch.Error{reason: reason}} ->
        end_time = System.monotonic_time()
        response_time_ms = System.convert_time_unit(end_time - start_time, :native, :millisecond)

        Logger.error("Check failed for #{endpoint.url}: Reason #{inspect(reason)}, Time #{response_time_ms}ms")

        result = %CheckResult{
          endpoint_id: endpoint.id,
          status_code: 0,
          response_time_ms: response_time_ms,
          success: false,
          error_message: "Finch Error: #{inspect(reason)}",
          checked_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
        }

        # Send notification for failed check
        Logger.info("Attempting to send notification for failed check of #{endpoint.url}")
        if endpoint.notification_email do
          Logger.info("Endpoint has notification email configured: #{endpoint.notification_email}")
          Notifier.notify(endpoint, "Check failed for #{endpoint.url}: #{inspect(reason)}")
        else
          Logger.info("No notification email configured for endpoint #{endpoint.url}")
        end

        Repo.insert(result)
    end
  end

  @doc """
  Converts a status code to a string representation.
  """
  defp status_to_string(status), do: Kernel.to_string(status)
end
