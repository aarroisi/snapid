defmodule Snapid.Repo.Migrations.AddUserToSnap do
  use Ecto.Migration

  def change do
    alter table(:threads) do
      add :user_id, :bigint
      add :slug, :string
      add :is_published, :boolean, default: true
    end
  end
end
