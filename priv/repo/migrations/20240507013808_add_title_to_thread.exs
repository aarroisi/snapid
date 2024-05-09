defmodule Snapid.Repo.Migrations.AddTitleToThread do
  use Ecto.Migration

  def change do
    alter table(:threads) do
      add :title, :string
      modify :body, :text
    end
  end
end
