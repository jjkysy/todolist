defmodule Todolist.Todos.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :content, :string
    field :completed, :boolean, default: false
    field :position, :integer
    belongs_to :list, Todolist.Todos.List

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:content, :completed, :position, :list_id])
    |> validate_required([:content, :list_id])
    |> foreign_key_constraint(:list_id)
  end
end
