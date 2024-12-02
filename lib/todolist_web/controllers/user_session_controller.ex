defmodule TodolistWeb.UserSessionController do
  use TodolistWeb, :controller

  alias Todolist.Accounts
  alias TodolistWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, params) do
    case params do
      %{"user" => %{"email" => email, "password" => password} = user_params} ->
        if user = Accounts.get_user_by_email_and_password(email, password) do
          conn
          |> put_flash(:info, "Welcome back!")
          |> UserAuth.log_in_user(user, user_params)
        else
          render(conn, :new, error_message: "Invalid email or password")
        end
      _ ->
        render(conn, :new, error_message: "Invalid form submission")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
