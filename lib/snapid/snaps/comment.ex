defmodule Snapid.Snaps.Comment do
  @moduledoc """
  This is Comment module that represent comments table in Snapid.
  """

  use Ecto.Schema
  alias Snapid.Snaps.Snap
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    field :user_id, :integer
    belongs_to :snap, Snap
    belongs_to :parent_comment, __MODULE__
    timestamps(type: :utc_datetime)
  end

  def changeset(comment, params) do
    comment
    |> cast(params, [:body, :user_id, :snap_id, :parent_comment_id])
    |> validate_required([:body, :user_id, :snap_id])
  end
end
