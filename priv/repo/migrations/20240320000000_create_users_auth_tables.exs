defmodule Todolist.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL,
      hashed_password TEXT NOT NULL,
      inserted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )"

    execute "CREATE UNIQUE INDEX IF NOT EXISTS users_email_index ON users (email)"

    execute "CREATE TABLE IF NOT EXISTS users_tokens (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      token TEXT NOT NULL,
      context TEXT NOT NULL,
      inserted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )"

    execute "CREATE UNIQUE INDEX IF NOT EXISTS users_tokens_context_token_index ON users_tokens (context, token)"
    execute "CREATE INDEX IF NOT EXISTS users_tokens_user_id_index ON users_tokens (user_id)"
  end
end
