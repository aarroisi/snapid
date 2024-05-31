defmodule Snapid.Snaps do
  @moduledoc """
  The Snaps context.
  """

  import Ecto.Query
  alias Snapid.Snaps.Comment
  alias Snapid.Repo
  alias SnapidWeb.Endpoint

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

  defp maybe_filter_by(query, key, value, opts \\ []) do
    literal_nil = Keyword.get(opts, :literal_nil, false)

    if not is_nil(value) do
      query
      |> where([s], field(s, ^key) == ^value)
    else
      if literal_nil do
        query
        |> where([s], field(s, ^key) |> is_nil())
      else
        query
      end
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

  # Users

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

  # Comments

  defp comment_base_filter(snap_id) when not is_nil(snap_id) do
    from(
      c in Comment,
      where: c.snap_id == ^snap_id
    )
  end

  def list_comments(snap_id, params \\ %{}) when not is_nil(snap_id) do
    page_size = Map.get(params, :page_size) || 25
    last_id = Map.get(params, :last_id)
    parent_comment_id = Map.get(params, :parent_comment_id)

    comments =
      comment_base_filter(snap_id)
      |> order_by([c], desc: c.inserted_at)
      |> limit([c], ^page_size)
      |> maybe_filter_by_id(last_id)
      |> maybe_filter_by(:parent_comment_id, parent_comment_id, literal_nil: true)
      |> Repo.all()
      |> Enum.reverse()

    user_ids =
      comments
      |> Enum.map(fn comment -> comment.user_id end)
      |> Enum.uniq()

    users = if length(user_ids) > 0, do: Snapid.Auth.get_users_by_ids(user_ids)["data"], else: []

    IO.inspect(users)

    comments
    |> Enum.map(fn comment ->
      user =
        Enum.find(users, fn user ->
          IO.inspect(user)

          user["id"] == comment.user_id
        end)

      comment |> Map.put(:user, user)
    end)
  end

  def total_comments_count(snap_id, parent_comment_id \\ nil) do
    comment_base_filter(snap_id)
    |> maybe_filter_by(:parent_comment_id, parent_comment_id, literal_nil: true)
    |> select([c], count(c))
    |> Repo.one()
  end

  defp maybe_filter_by_id(query, last_id) do
    if is_nil(last_id) do
      query
    else
      query
      |> where([c], c.id < ^last_id)
    end
  end

  def get_comment!(id) do
    Repo.get!(Comment, id)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        user = Snapid.Auth.get_user_by_id(comment.user_id)["data"]
        comment = Map.put(comment, :user, user)

        publish_comment_created({:ok, comment})

        {:ok, comment}

      {:error, error} ->
        {:error, error}
    end
  end

  def update_comment(%Comment{} = snap, attrs) do
    snap
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def publish_comment_created({:ok, comment} = result) do
    event =
      if not is_nil(comment.parent_comment_id) do
        "new_reply"
      else
        "new_comment"
      end

    Endpoint.broadcast("snap:#{comment.snap_id}", event, %{comment: comment})

    result
  end

  def publish_message_created(result), do: result
end
