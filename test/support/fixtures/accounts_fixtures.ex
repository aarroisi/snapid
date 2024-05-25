defmodule Snapid.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snapid.Accounts` context.
  """
  alias Snapid.Accounts.User

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture() do
    %User{
      id: System.unique_integer(),
      email: unique_user_email(),
      fullname: "John Doe"
    }
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
