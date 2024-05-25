defmodule Snapid.Auth do
  def login(email, password) do
    url = get_base_url() <> "/api/users/log_in"
    body = %{email: email, password: password}
    response = Req.post!(url, json: body)
    response.body
  end

  def get_user_by_id(id) do
    token = System.get_env("PRIVATE_TOKEN") || ""
    url = get_base_url() <> "/api/users/#{id}"
    headers = [{"Authorization", "Bearer #{token}"}]
    response = Req.get!(url, headers: headers)
    response.body
  end

  defp get_base_url() do
    case System.get_env("ENVIRONMENT") do
      "local" -> "http://localhost:9000"
      _ -> "https://nexus.scalev.id"
    end
  end
end
