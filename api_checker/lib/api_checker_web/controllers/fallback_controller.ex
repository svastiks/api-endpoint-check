defmodule ApiCheckerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  use ApiCheckerWeb, :controller

  # Handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ApiCheckerWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # Handles resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: ApiCheckerWeb.ErrorHTML, json: ApiCheckerWeb.ErrorJSON)
    |> render(:"404")
  end
end
