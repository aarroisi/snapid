defmodule Snapid.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Snapid.Repo

  alias Snapid.Accounts.{User, UserToken}

  @session_validity_in_days 60

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    Snapid.Auth.login(email, password)
    |> handle_auth_login()
  end

  def get_user_by_email_and_password(_email, _password), do: nil

  defp handle_auth_login(response) do
    case response do
      %{"data" => user} ->
        %User{
          id: user["id"],
          email: user["email"],
          fullname: user["fullname"]
        }

      _ ->
        nil
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in UserToken.by_token_and_context_query(token, "session"),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: token.user_id

    {:ok, query}
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = verify_session_token_query(token)

    Repo.one(query)
    |> Snapid.Auth.get_user_by_id()
    |> handle_auth_login()
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end
end
