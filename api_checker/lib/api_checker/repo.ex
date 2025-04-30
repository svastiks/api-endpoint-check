defmodule ApiChecker.Repo do
  use Ecto.Repo,
    otp_app: :api_checker,
    adapter: Ecto.Adapters.Postgres
end
