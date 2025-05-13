defmodule ApiChecker.Endpoints do
  @moduledoc """
  The Endpoints context.
  """

  import Ecto.Query, warn: false
  alias ApiChecker.Repo
  alias ApiChecker.Endpoints.Endpoint
  alias ApiChecker.Accounts.User

  @doc """
  Returns the list of endpoints for a user.
  """
  def list_endpoints(%User{} = user) do
    from(e in Endpoint, where: e.user_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Returns the list of active endpoints for a user.
  """
  def list_active_endpoints(%User{} = user) do
    from(e in Endpoint, where: e.active == true and e.user_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single endpoint.
  Returns nil if the Endpoint does not exist or is not active.
  """
  def get_endpoint(%User{} = user, id) do
    from(e in Endpoint, where: e.id == ^id and e.active == true and e.user_id == ^user.id)
    |> Repo.one()
  end

  @doc """
  Creates a endpoint for a user.
  """
  def create_endpoint(%User{} = user, attrs \\ %{}) do
    %Endpoint{}
    |> Endpoint.changeset(Map.put(attrs, "user_id", user.id))
    |> Repo.insert()
  end

  @doc """
  Updates a endpoint.
  """
  def update_endpoint(%Endpoint{} = endpoint, attrs) do
    endpoint
    |> Endpoint.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a endpoint.
  """
  def delete_endpoint(%Endpoint{} = endpoint) do
    Repo.delete(endpoint)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking endpoint changes.
  """
  def change_endpoint(%Endpoint{} = endpoint, attrs \\ %{}) do
    Endpoint.changeset(endpoint, attrs)
  end

  @doc """
  Lists all endpoints for a given user.
  """
  def list_user_endpoints(%User{} = user) do
    Repo.all(from e in Endpoint, where: e.user_id == ^user.id, order_by: e.name)
  end

  @doc """
  Gets a single endpoint by ID, ensuring it belongs to the user.
  Returns the endpoint or nil.
  """
  def get_user_endpoint(%User{} = user, id) do
     Repo.get_by(Endpoint, id: id, user_id: user.id)
  end

  @doc """
  Returns a list of all results for that endpoint
  """
  def list_check_results_for_endpoint(endpoint_id, limit \\ 10) do
    import Ecto.Query
    endpoint_id =
      case endpoint_id do
        id when is_binary(id) -> String.to_integer(id)
        id -> id
      end

    ApiChecker.Repo.all(
      from cr in ApiChecker.Endpoints.CheckResult,
        where: cr.endpoint_id == ^endpoint_id,
        order_by: [desc: cr.checked_at],
        limit: ^limit
    )
  end

  def get_endpoint!(id) do
    Repo.get!(Endpoint, id)
  end

end
