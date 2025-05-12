defmodule ApiCheckerWeb.Router do
  use ApiCheckerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()
  end

  # Scope for Protected API routes
  scope "/api", ApiCheckerWeb do
    pipe_through [:api, ApiCheckerWeb.AuthPlug]

    resources "/endpoints", EndpointController, except: [:new, :edit]
    get "/check_results/:endpoint_id", CheckResultController, :index
  end

  # Scope for Unprotected API routes
  scope "/api", ApiCheckerWeb do
    pipe_through :api

    post "/register", UserController, :register
    post "/login", UserController, :login
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:api_checker, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ApiCheckerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
