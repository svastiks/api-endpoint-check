defmodule ApiChecker.Repo.Migrations.CreateEndpoints do
  use Ecto.Migration

  def change do
    create table(:endpoints) do
      add :url, :string, null: false
      add :check_interval_seconds, :integer, default: 60, null: false
      add :active, :boolean, default: true, null: false
      add :name, :string
      add :notification_email, :string
      add :notification_slack_webhook, :string

      timestamps()
    end

    create unique_index(:endpoints, [:url])
  end
end
