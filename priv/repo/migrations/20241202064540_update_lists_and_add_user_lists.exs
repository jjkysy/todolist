defmodule Todolist.Repo.Migrations.UpdateListsAndAddUserLists do
  use Ecto.Migration

  def change do
    # Create user_lists table for many-to-many relationship
    create table(:user_lists) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :list_id, references(:lists, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_lists, [:user_id])
    create index(:user_lists, [:list_id])
    create unique_index(:user_lists, [:user_id, :list_id])
  end
end
