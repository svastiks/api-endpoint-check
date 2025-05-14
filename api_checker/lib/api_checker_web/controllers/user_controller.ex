defmodule ApiCheckerWeb.UserController do
  use ApiCheckerWeb, :controller
  alias ApiChecker.Accounts
  require Logger

  def register(conn, %{"email" => email, "password" => password}) do
    Logger.info("UserController.register called with params: #{inspect(%{email: email, password: password})}")
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
    Logger.info("UserController.login called with params: #{inspect(%{email: email, password: password})}")
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
