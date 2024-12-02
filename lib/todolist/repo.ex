defmodule Todolist.Repo do
  use Ecto.Repo,
    otp_app: :todolist,
    adapter: Ecto.Adapters.SQLite3
end
