defmodule Clients.Storage.S3 do
  def upload(%{
        "Content-Type" => content_type,
        "file" => %Plug.Upload{path: tmp_path},
        "key" => key
      }) do
    file_path = "#{key}.#{ext(content_type)}"
    file = File.read!(tmp_path)

    ExAws.S3.put_object(bucket_name(), file_path, file, content_type: content_type)
    |> ExAws.request()
    |> case do
      {:ok, _response} -> {:ok, build_url(file_path)}
      {:error, error} -> {:error, error}
    end
  end

  def delete_file(file_url) do
    ExAws.S3.delete_object(bucket_name(), file_url)
    |> ExAws.request()
    |> case do
      {:ok, %{status_code: 204}} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  defp ext(content_type) do
    [ext | _] = MIME.extensions(content_type)
    ext
  end

  defp build_url(file_path) do
    base_url = System.get_env("AWS_ENDPOINT_URL_S3")
    "https://#{base_url}/#{bucket_name()}/#{file_path}"
  end

  defp bucket_name() do
    System.get_env("BUCKET_NAME")
  end
end
