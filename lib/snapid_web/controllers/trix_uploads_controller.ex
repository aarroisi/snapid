defmodule SnapidWeb.TrixUploadsController do
  use SnapidWeb, :controller

  def create(conn, params) do
    case impl().upload(params) do
      {:ok, file_url} -> send_resp(conn, 201, file_url)
      {:error, _reason} -> send_resp(conn, 400, "Unable to upload file.")
    end
  end

  def delete(conn, %{"key" => key}) do
    case impl().delete_file(key) do
      :ok -> send_resp(conn, 204, "File successfully deleted")
      {:error, _reason} -> send_resp(conn, 400, "Unable to delete file, please try again later.")
    end
  end

  defp impl, do: Application.get_env(:snapid, :uploader)[:adapter]
end
