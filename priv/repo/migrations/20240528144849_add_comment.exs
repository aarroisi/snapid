defmodule Snapid.Repo.Migrations.AddComment do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text
      add :user_id, :bigint
      add :snap_id, references(:threads, on_delete: :delete_all), null: false
      add :parent_comment_id, references(:comments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:user_id, :snap_id, :parent_comment_id])
  end
end
