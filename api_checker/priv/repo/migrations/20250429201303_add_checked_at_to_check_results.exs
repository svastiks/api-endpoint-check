defmodule ApiChecker.Repo.Migrations.AddCheckedAtToCheckResults do
  use Ecto.Migration

  def change do
    alter table(:check_results) do
      add :checked_at, :naive_datetime, null: false
    end
  end
end
