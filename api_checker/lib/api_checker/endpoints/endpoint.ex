defmodule ApiChecker.Endpoints.Endpoint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "endpoints" do
    field :active, :boolean, default: false
    field :name, :string
    field :url, :string
    field :check_interval_seconds, :integer
    field :notification_email, :string
    field :notification_slack_webhook, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(endpoint, attrs) do
    endpoint
    |> cast(attrs, [:url, :check_interval_seconds, :active, :name, :notification_email, :notification_slack_webhook])
    |> validate_required([:url, :check_interval_seconds, :active, :name])
  end
end
