defmodule ApiChecker.Accounts do
  @moduledoc """
  The Accounts context for managing users.
  """

  alias ApiChecker.Accounts.User
  alias ApiChecker.Repo

  require Logger

  @doc """
  Creates a new user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticates a user by email and password.
  """
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      %User{hashed_password: hashed_password} when not is_nil(hashed_password) ->
        if Bcrypt.check_pass(password, hashed_password) do
            Logger.info("User authenticated successfully: #{email}")
            {:ok, user}
        else
          Logger.warning("Authentication failed for user (invalid password): #{email}")
          {:error, :unauthorized}
        end
      _ ->
        Logger.warning("Authentication failed for user (not found or no password): #{email}")
        {:error, :unauthorized}
    end
  end

  @doc """
  Gets a user by their email address.
  Returns `%User{}` or `nil`.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  """
  Token generation
  """
  def login_user(email, password) do
    case authenticate_user(email, password) do
        {:ok, user} ->
          token = :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> binary_part(0, 32)
          changeset = Ecto.Changeset.change(user, token: token)
          case Repo.update(changeset) do
            {:ok, user} -> {:ok, token, user}
            error -> error
          end
        error -> error
      end
    end

    def get_user_by_token(token) do
      # Ensure token is not nil or empty before querying
      if token && token != "" do
        Repo.get_by(User, token: token)
      else
        nil
      end
    end

end
