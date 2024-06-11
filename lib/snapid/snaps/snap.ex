defmodule Snapid.Snaps.Snap do
  use Ecto.Schema
  alias Ecto.Changeset
  import Ecto.Changeset

  schema "snaps" do
    field :title, :string
    field :description, :string
    field :body, :string
    field :slug, :string
    field :is_published, :boolean, default: true

    belongs_to :user, Snapid.Accounts.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(snap, attrs) do
    snap
    |> cast(attrs, [:title, :description, :body, :user_id, :slug, :is_published])
    |> maybe_put_slug()
    |> validate_length(:title, max: 255)
    |> validate_length(:description, max: 255)
    |> validate_required([:title, :body, :user_id, :slug])
    |> unique_constraint(:slug)
  end

  defp maybe_put_slug(%Changeset{} = changeset) do
    case get_field(changeset, :slug) do
      nil -> put_change(changeset, :slug, generate_slug() |> Slug.slugify())
      _ -> changeset
    end
  end

  defp generate_slug() do
    random_string(8)
  end

  def random_string(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
