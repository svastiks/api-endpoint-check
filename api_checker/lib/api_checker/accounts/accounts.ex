defmodule ApiChecker.Accounts do
  @moduledoc """
  The Accounts context for managing users.
  """

  alias ApiChecker.Accounts.User
  alias ApiChecker.Repo

  require Logger

  @doc """
  Creates a new user.

  Accepts a map of user attributes.
  Returns `{:ok, user}` if the user was created successfully,
  or `{:error, changeset}` otherwise.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticates a user by email and password.

  Returns `{:ok, user}` if authentication is successful,
  or `{:error, :unauthorized}` otherwise.
  """
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      %User{hashed_password: hashed_password} when not is_nil(hashed_password) ->
        # Use Bcrypt.checkpw to verify the password
        if Bcrypt.checkpw(password, hashed_password) do
          # Optional: Check if the user is confirmed
          # if user.confirmed_at do
            Logger.info("User authenticated successfully: #{email}")
            {:ok, user}
          # else
          #   Logger.warning("Authentication failed for user (not confirmed): #{email}")
          #   {:error, :not_confirmed} # You can define different error atoms
          # end
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

  # You can add other functions here as needed, e.g.:
  # def update_user(user, attrs) do ... end
  # def delete_user(user) do ... end
  # def confirm_user(user) do ... end
end
