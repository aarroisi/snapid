defmodule Snapid.Repo.Migrations.AddIndexUser do
  use Ecto.Migration

  def change do
    create index(:threads, [:user_id, :is_published, :slug])
  end
end
