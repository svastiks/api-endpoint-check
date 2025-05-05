defmodule ApiChecker.Endpoints.CheckResult do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [
    :id,
    :status_code,
    :response_time_ms,
    :success,
    :error_message,
    :checked_at,
    :endpoint_id,
    :inserted_at,
    :updated_at
  ]}

  schema "check_results" do
    field :status_code, :integer
    field :response_time_ms, :integer
    field :success, :boolean
    field :error_message, :string
    field :checked_at, :naive_datetime

    belongs_to :endpoint, ApiChecker.Endpoints.Endpoint

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(check_result, attrs) do
    check_result
    |> cast(attrs, [:status_code, :response_time_ms, :success, :error_message, :endpoint_id, :checked_at])
    |> validate_required([:status_code, :response_time_ms, :success, :endpoint_id, :checked_at])
    |> foreign_key_constraint(:endpoint_id)
  end
end
