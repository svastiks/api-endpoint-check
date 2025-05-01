defmodule ApiChecker.Repo.Migrations.AddUserToEndpoints do
  use Ecto.Migration

  def change do
    alter table(:endpoints) do
      # Foreign Key
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    # Index for faster lookups by user
    create index(:endpoints, [:user_id])
  end
end
