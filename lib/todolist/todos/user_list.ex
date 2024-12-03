defmodule Todolist.Todos.UserListShare do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_list_shares" do
    belongs_to :user, Todolist.Accounts.User
    belongs_to :list, Todolist.Todos.List

    timestamps()
  end

  @doc false
  def changeset(user_list_share, attrs) do
    user_list_share
    |> cast(attrs, [:user_id, :list_id])
    |> validate_required([:user_id, :list_id])
    |> unique_constraint([:user_id, :list_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:list_id)
  end
end
