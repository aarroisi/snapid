defmodule SnapidWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(SnapidWeb.ErrorHTML)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(SnapidWeb.ErrorHTML)
    |> render(:"403")
  end
end
