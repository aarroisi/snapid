defmodule Snapid.Repo do
  use Ecto.Repo,
    otp_app: :snapid,
    adapter: Ecto.Adapters.Postgres
end
