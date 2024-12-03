defmodule TodolistWeb.Router do
  use TodolistWeb, :router

  import TodolistWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TodolistWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", TodolistWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Authentication routes
  scope "/", TodolistWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  # Protected routes
  scope "/", TodolistWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/lists", Lists.IndexLive
    live "/lists/:id", Lists.ShowLive
  end

  scope "/", TodolistWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
