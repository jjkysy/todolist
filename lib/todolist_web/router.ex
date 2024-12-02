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

    get "/register", UserRegistrationController, :new
    post "/register", UserRegistrationController, :create
    get "/login", UserSessionController, :new
    post "/login", UserSessionController, :create
  end

  # Protected routes
  scope "/", TodolistWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/lists", TodoListLive
    live "/lists/:id", TodoItemsLive
  end

  scope "/", TodolistWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete
  end
end
