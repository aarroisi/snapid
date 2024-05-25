defmodule Snapid.Snaps do
  @moduledoc """
  The Snaps context.
  """

  import Ecto.Query
  alias Snapid.Repo

  alias Snapid.Snaps.Snap

  @doc """
  Returns the list of snaps.

  ## Examples

      iex> list_snaps()
      [%Snap{}, ...]

  """
  def list_snaps(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)

    from(
      s in Snap,
      order_by: [desc: s.inserted_at],
      limit: 25
    )
    |> maybe_filter_by(:user_id, user_id)
    |> Repo.all()
  end

  defp maybe_filter_by(query, key, value) do
    if not is_nil(value) do
      query
      |> where([s], field(s, ^key) == ^value)
    else
      query
    end
  end

  @doc """
  Gets a single snap.

  Raises `Ecto.NoResultsError` if the Snap does not exist.

  ## Examples

      iex> get_snap!(123)
      %Snap{}

      iex> get_snap!(456)
      ** (Ecto.NoResultsError)

  """
  def get_snap!(id, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)

    from(
      s in Snap,
      where: s.id == ^id
    )
    |> maybe_filter_by(:user_id, user_id)
    |> Repo.one()
    |> load_user()
  end

  @doc """
  Gets a single snap.

  Raises `Ecto.NoResultsError` if the Snap does not exist.

  ## Examples

      iex> get_snap!(123)
      %Snap{}

      iex> get_snap!(456)
      ** (Ecto.NoResultsError)

  """
  def get_snap_by_slug!(slug) do
    Repo.get_by!(Snap, slug: slug, is_published: true)
    |> load_user()
  end

  @doc """
  Creates a snap.

  ## Examples

      iex> create_snap(%{field: value})
      {:ok, %Snap{}}

      iex> create_snap(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_snap(attrs \\ %{}) do
    %Snap{}
    |> Snap.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a snap.

  ## Examples

      iex> update_snap(snap, %{field: new_value})
      {:ok, %Snap{}}

      iex> update_snap(snap, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_snap(%Snap{} = snap, attrs) do
    snap
    |> Snap.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a snap.

  ## Examples

      iex> delete_snap(snap)
      {:ok, %Snap{}}

      iex> delete_snap(snap)
      {:error, %Ecto.Changeset{}}

  """
  def delete_snap(%Snap{} = snap) do
    Repo.delete(snap)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking snap changes.

  ## Examples

      iex> change_snap(snap)
      %Ecto.Changeset{data: %Snap{}}

  """
  def change_snap(%Snap{} = snap, attrs \\ %{}) do
    Snap.changeset(snap, attrs)
  end

  defp load_user(%Snap{} = snap) do
    user =
      case snap.user_id do
        nil ->
          %{}

        _ ->
          %{"data" => user} =
            snap.user_id
            |> Snapid.Auth.get_user_by_id()

          user
      end

    snap
    |> Map.put(:user, user)
  end

  defp load_user(nil), do: nil
end
