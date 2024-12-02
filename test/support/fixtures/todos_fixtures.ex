defmodule Todolist.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todolist.Todos` context.
  """

  alias Todolist.Accounts
  alias Todolist.Todos

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello123456"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    user
  end

  def list_fixture(user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "Test List #{System.unique_integer()}",
        position: System.unique_integer([:positive])
      })

    {:ok, list} = Todos.create_list(user, attrs)
    list
  end

  def item_fixture(list, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "Test Item #{System.unique_integer()}",
        completed: false,
        position: System.unique_integer([:positive]),
        list_id: list.id
      })

    {:ok, item} = Todos.create_item(attrs)
    item
  end

  def user_list_share_fixture(list, user) do
    {:ok, share} = Todos.share_list(list, user)
    share
  end
end
