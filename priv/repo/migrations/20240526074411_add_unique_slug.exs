defmodule Snapid.Repo.Migrations.AddUniqueSlug do
  use Ecto.Migration

  def change do
    create unique_index(:threads, [:slug])
  end
end
