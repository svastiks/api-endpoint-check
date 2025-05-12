defmodule ApiChecker.Endpoints.Endpoint do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  schema "endpoints" do
    field :active, :boolean, default: false
    field :name, :string
    field :url, :string
    field :check_interval_seconds, :integer
    field :notification_email, :string
    field :notification_slack_webhook, :string

    belongs_to :user, ApiChecker.Accounts.User

    has_many :check_results, ApiChecker.Endpoints.CheckResult
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(endpoint, attrs) do
    changeset =
      endpoint
      |> cast(attrs, [:url, :check_interval_seconds, :active, :name, :notification_email, :notification_slack_webhook, :user_id])

    changeset
    |> validate_required([:url, :check_interval_seconds, :active, :name, :user_id])
  end
end
