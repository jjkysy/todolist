defmodule Todolist.Repo.Migrations.CreateTodoItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :content, :string, null: false
      add :completed, :boolean, default: false, null: false
      add :position, :integer
      add :list_id, references(:lists, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:items, [:list_id])
  end
end
