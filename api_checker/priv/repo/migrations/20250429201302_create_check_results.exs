defmodule ApiChecker.Repo.Migrations.CreateCheckResults do
  use Ecto.Migration

  def change do
    create table(:check_results) do
      add :status_code, :integer, null: false
      add :response_time_ms, :integer, null: false
      add :success, :boolean, null: false
      add :error_message, :string
      add :checked_at, :naive_datetime, null: false
      add :endpoint_id, references(:endpoints, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:check_results, [:endpoint_id])
  end
end
