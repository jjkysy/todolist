defmodule Todolist.Repo.Migrations.CreateTodoLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :title, :string, null: false
      add :position, :integer
      add :owner_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:lists, [:owner_id])
  end
end
