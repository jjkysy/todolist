defmodule Todolist.Repo.Migrations.CreateUserListShares do
  use Ecto.Migration

  def change do
    create table(:user_list_shares) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :list_id, references(:lists, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_list_shares, [:user_id])
    create index(:user_list_shares, [:list_id])
    create unique_index(:user_list_shares, [:user_id, :list_id])
  end
end
