defmodule SnapidWeb.Router do
  use SnapidWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SnapidWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SnapidWeb do
    pipe_through :browser

    get "/", ThreadController, :home
    get "/threads", ThreadController, :home

    post "/trix-uploads", TrixUploadsController, :create
    delete "/trix-uploads", TrixUploadsController, :delete

    live "/snaps", SnapLive.Index, :index
    live "/snaps/new", SnapLive.New, :new
    live "/snaps/:id/edit", SnapLive.Show, :edit
    live "/snaps/:id", SnapLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", SnapidWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:snapid, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SnapidWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
