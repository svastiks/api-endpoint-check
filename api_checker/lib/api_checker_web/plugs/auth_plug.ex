defmodule ApiCheckerWeb.AuthPlug do
  import Plug.Conn
  alias ApiChecker.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case Accounts.get_user_by_token(token) do
          nil -> unauthorized(conn)
          user -> assign(conn, :current_user, user)
        end
      _ -> unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, Jason.encode!(%{error: "Unauthorized"}))
    |> halt()
  end
end
