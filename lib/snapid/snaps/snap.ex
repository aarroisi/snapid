defmodule Snapid.Snaps.Snap do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :title, :string
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(snap, attrs) do
    snap
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
