defmodule ApiChecker.CheckerSupervisor do
  use GenServer
  require Logger

  alias ApiChecker.Endpoints
  alias ApiChecker.Endpoints.Endpoint
  alias ApiChecker.Checker
  alias ApiChecker.Repo

  # Check for new endpoints every 30 seconds
  @check_interval 10_000

  # Client API (for starting and stopping the GenServer)
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # GenServer Callbacks

  @impl true
  def init(:ok) do
    # Initial state will hold the timer references for each endpoint
    {:ok, %{}, {:continue, :schedule_all_endpoints}}
  end

  @impl true
  def handle_continue(:schedule_all_endpoints, state) do
    Logger.info("Scheduling initial endpoint checks...")
    endpoints = Endpoints.list_active_endpoints()

    new_state = Enum.reduce(endpoints, state, fn endpoint, acc ->
      schedule_check(endpoint, acc)
    end)

    # Schedule periodic endpoint list checking
    Process.send_after(self(), :check_new_endpoints, @check_interval)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:check_new_endpoints, state) do
    Logger.info("Checking for new endpoints...")
    all_endpoints = Endpoints.list_active_endpoints()

    # Find new endpoints that aren't being checked yet
    new_endpoints = Enum.filter(all_endpoints, fn endpoint ->
      not Map.has_key?(state, endpoint.id)
    end)

    # Schedule checks for new endpoints
    new_state = Enum.reduce(new_endpoints, state, fn endpoint, acc ->
      schedule_check(endpoint, acc)
    end)

    # Schedule next check
    Process.send_after(self(), :check_new_endpoints, @check_interval)

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:check_endpoint, endpoint_id}, state) do
    Logger.info("Received check command for endpoint ID: #{endpoint_id}")
    case Endpoints.get_endpoint(endpoint_id) do
      nil ->
        Logger.warning("Endpoint with ID #{endpoint_id} not found or is not active.")
        # Remove the timer from the state if the endpoint is gone
        new_state = Map.delete(state, endpoint_id)
        {:noreply, new_state}

      endpoint ->
        # Schedule the next check before performing the current one
        new_state = schedule_check(endpoint, state)

        # Perform the check in a separate task to avoid blocking the GenServer
        Task.start(fn ->
          Checker.check_and_record(endpoint)
        end)

        {:noreply, new_state}
    end
  end

  # Handle endpoint updates (Optional but good practice)
  @impl true
  def handle_info({:endpoint_updated, endpoint}, state) do
    Logger.info("Endpoint updated: #{endpoint.id}")
    # Reschedule the check for the updated endpoint
    new_state = cancel_check(endpoint.id, state) # Cancel any existing timer
    new_state = schedule_check(endpoint, new_state)
    {:noreply, new_state}
  end

  # Handle endpoint deletions (Optional but good practice)
  @impl true
  def handle_info({:endpoint_deleted, endpoint_id}, state) do
    Logger.info("Endpoint deleted: #{endpoint_id}")
    # Cancel and remove the timer for the deleted endpoint
    new_state = cancel_check(endpoint_id, state)
    {:noreply, new_state}
  end

  # Helper function to schedule a check
  defp schedule_check(%Endpoint{} = endpoint, state) do
    # Cancel any existing timer for this endpoint before scheduling a new one
    state = cancel_check(endpoint.id, state)

    timer_ref = Process.send_after(self(), {:check_endpoint, endpoint.id}, endpoint.check_interval_seconds * 1000)
    Logger.info("Scheduled check for endpoint ID #{endpoint.id} (#{endpoint.url}) in #{endpoint.check_interval_seconds} seconds.")
    Map.put(state, endpoint.id, timer_ref)
  end

  # Helper function to cancel a scheduled check
  defp cancel_check(endpoint_id, state) do
    if timer_ref = Map.get(state, endpoint_id) do
      Logger.info("Cancelling scheduled check for endpoint ID: #{endpoint_id}")
      Process.cancel_timer(timer_ref)
      Map.delete(state, endpoint_id)
    else
      state # No timer found for this endpoint
    end
  end
end
