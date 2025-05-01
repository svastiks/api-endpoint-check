defmodule ApiCheckerWeb.UserController do
  use ApiCheckerWeb, :controller
  alias ApiChecker.Accounts

  def register(conn, %{"email" => email, "password" => password}) do
    case Accounts.create_user(%{email: email, password: password}) do
      {:ok, user} ->
        json(conn, %{id: user.id, email: user.email})
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: changeset.errors})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.login_user(email, password) do
      {:ok, token, user} ->
        json(conn, %{token: token, user_id: user.id, email: user.email})
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end
end
