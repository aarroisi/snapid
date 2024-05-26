defmodule Snapid.Repo.Migrations.AddOgDesc do
  use Ecto.Migration

  def change do
    alter table(:threads) do
      add :description, :string
    end
  end
end
