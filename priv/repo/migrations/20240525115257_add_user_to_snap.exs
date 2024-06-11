defmodule Snapid.Repo.Migrations.AddUserToSnap do
  use Ecto.Migration

  def change do
    create table(:snaps) do
      add :body, :text
      add :title, :string
      add :description, :string
      add :slug, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :is_published, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create index(:snaps, [:user_id, :is_published, :slug])
    create unique_index(:snaps, [:slug])
  end
end
