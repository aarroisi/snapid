defmodule Snapid.Accounts.User do
  @enforce_keys [:id, :email, :fullname]
  defstruct [:id, :email, :fullname]

  @type t() :: %__MODULE__{
          id: integer(),
          email: String.t(),
          fullname: String.t()
        }
end
