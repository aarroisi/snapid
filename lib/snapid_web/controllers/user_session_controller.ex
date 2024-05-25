defmodule SnapidWeb.UserSessionController do
  use SnapidWeb, :controller

  alias Snapid.Accounts
  alias Snapid.Accounts.User
  alias SnapidWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    params = Map.put(params, "remember_me", "true")
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    params = Map.put(params, "remember_me", "true")

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    params = Map.put(params, "remember_me", "true")
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      nil ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
