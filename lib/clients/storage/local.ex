defmodule Clients.Storage.Local do
  @moduledoc """
  Storage module to store files locally.
  """

  def upload(%{
        "Content-Type" => content_type,
        "file" => %Plug.Upload{path: tmp_path},
        "key" => key
      }) do
    # Create uploads dir if not exist
    create_uploads_dir()

    # Generate unique filename
    file_name = "#{key}.#{ext(content_type)}"

    # Copy file to file system
    case File.cp(tmp_path, Path.join(uploads_dir(), file_name)) do
      :ok -> {:ok, Path.join("/uploads", file_name)}
      error -> error
    end
  end

  def delete_file(file_url) do
    "priv/static"
    |> Path.join(file_url)
    |> File.rm()
    |> case do
      :ok -> :ok
      error -> error
    end
  end

  defp ext(content_type) do
    [ext | _] = MIME.extensions(content_type)
    ext
  end

  defp uploads_dir, do: Path.join(["priv", "static", "uploads"])
  defp create_uploads_dir, do: File.mkdir_p!(uploads_dir())
end
