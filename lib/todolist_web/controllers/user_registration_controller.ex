defmodule TodolistWeb.UserRegistrationController do
  use TodolistWeb, :controller

  alias Todolist.Accounts
  alias Todolist.Accounts.User
  alias TodolistWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params) do
    IO.inspect(params, label: "Registration Params")
    case params do
      %{"user" => user_params} ->
        case Accounts.register_user(user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User created successfully.")
            |> UserAuth.log_in_user(user)

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset)
        end
      _ ->
        changeset = Accounts.change_user_registration(%User{})
        |> Ecto.Changeset.add_error(:email, "Invalid form submission")
        render(conn, :new, changeset: changeset)
    end
  end
end
