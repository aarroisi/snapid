defmodule Snapid.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :body, :string

      timestamps(type: :utc_datetime)
    end
  end
end
