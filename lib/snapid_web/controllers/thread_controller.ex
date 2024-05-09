defmodule SnapidWeb.ThreadController do
  use SnapidWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/snaps")
  end
end
