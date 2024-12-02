defmodule Todolist.Todos.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string
    field :position, :integer
    belongs_to :owner, Todolist.Accounts.User
    has_many :items, Todolist.Todos.Item
    many_to_many :shared_users, Todolist.Accounts.User, join_through: "user_lists"

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :position, :owner_id])
    |> validate_required([:title, :owner_id])
    |> foreign_key_constraint(:owner_id)
  end
end
