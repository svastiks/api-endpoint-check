defmodule ApiChecker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Bcrypt

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime
    field :password, :string, virtual: true
    field :token, :string

    has_many :endpoints, ApiChecker.Endpoints.Endpoint

    timestamps()
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :confirmed_at])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 8) # Enforce a minimum password length
    |> unique_constraint(:email)
    |> put_hashed_password() # Custom function to hash the password
    |> validate_email()
  end

  @doc false
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :confirmed_at])
    |> put_change(:password, attrs[:password])
    |> validate_length(:password, min: 8) # Enforce a minimum password length
    |> unique_constraint(:email)
    |> put_hashed_password()
    |> validate_email()
  end

  # Custom function to hash the password if provided
  defp put_hashed_password(changeset) do
    case get_change(changeset, :password) do
        nil -> changeset
        password ->
          put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end

  # Helper to validate email format (optional but recommended)
  @doc """
  Validates the format of the email address.
  """
  def validate_email(changeset, field \\ :email) do
    validate_change(changeset, field, fn _, email ->
      if Regex.match?(~r/^[^\s]+@[^\s]+\.[^\s]+$/, email) do
        [] # No errors
      else
        [{field, "has invalid format"}]
      end
    end)
  end
end
