defmodule Todolist.TodosTest do
  use Todolist.DataCase

  alias Todolist.Todos
  alias Todolist.Accounts
  alias Todolist.Todos.{List, Item}

  describe "lists" do
    setup do
      {:ok, user} =
        Accounts.register_user(%{
          email: "test@example.com",
          password: "hello123456"
        })

      {:ok, other_user} =
        Accounts.register_user(%{
          email: "other@example.com",
          password: "hello123456"
        })

      %{user: user, other_user: other_user}
    end

    test "list_lists/1 returns all user's lists", %{user: user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      assert [retrieved_list] = Todos.list_lists(user)
      assert retrieved_list.id == list.id
    end

    test "list_lists/1 returns shared lists", %{user: user, other_user: other_user} do
      {:ok, list} = Todos.create_list(other_user, %{title: "Shared List"})
      {:ok, _} = Todos.share_list(list, user)
      
      lists = Todos.list_lists(user)
      assert Enum.any?(lists, fn l -> l.id == list.id end)
    end

    test "get_user_list!/2 returns the list with given id", %{user: user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      assert Todos.get_user_list!(user.id, list.id).id == list.id
    end

    test "create_list/2 with valid data creates a list", %{user: user} do
      valid_attrs = %{title: "Test List", position: 42}
      assert {:ok, %List{} = list} = Todos.create_list(user, valid_attrs)
      assert list.title == "Test List"
      assert list.position == 42
      assert list.owner_id == user.id
    end

    test "create_list/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Todos.create_list(user, %{title: nil})
    end

    test "can_access_list?/2 returns true for list owner", %{user: user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      assert Todos.can_access_list?(user, list)
    end

    test "can_access_list?/2 returns true for shared user", %{user: user, other_user: other_user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      {:ok, _} = Todos.share_list(list, other_user)
      assert Todos.can_access_list?(other_user, list)
    end

    test "can_access_list?/2 returns false for non-owner and non-shared user", %{user: user, other_user: other_user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      refute Todos.can_access_list?(other_user, list)
    end

    test "share_list/2 shares a list with another user", %{user: user, other_user: other_user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      {:ok, _} = Todos.share_list(list, other_user)
      
      shared_users = Todos.list_shared_users(list)
      assert Enum.any?(shared_users, fn u -> u.id == other_user.id end)
    end

    test "unshare_list/2 removes list sharing", %{user: user, other_user: other_user} do
      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      {:ok, _} = Todos.share_list(list, other_user)
      {:ok, _} = Todos.unshare_list(list, other_user)
      
      shared_users = Todos.list_shared_users(list)
      refute Enum.any?(shared_users, fn u -> u.id == other_user.id end)
    end
  end

  describe "items" do
    setup do
      {:ok, user} =
        Accounts.register_user(%{
          email: "test@example.com",
          password: "hello123456"
        })

      {:ok, list} = Todos.create_list(user, %{title: "Test List"})
      %{user: user, list: list}
    end

    test "list_items/1 returns all list's items", %{list: list} do
      {:ok, item} = Todos.create_item(%{content: "Test Item", list_id: list.id})
      assert [retrieved_item] = Todos.list_items(list)
      assert retrieved_item.id == item.id
    end

    test "get_item!/1 returns the item with given id", %{list: list} do
      {:ok, item} = Todos.create_item(%{content: "Test Item", list_id: list.id})
      assert Todos.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item", %{list: list} do
      valid_attrs = %{content: "Test Item", completed: true, position: 42, list_id: list.id}
      assert {:ok, %Item{} = item} = Todos.create_item(valid_attrs)
      assert item.content == "Test Item"
      assert item.completed == true
      assert item.position == 42
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_item(%{content: nil})
    end

    test "update_item/2 with valid data updates the item", %{list: list} do
      {:ok, item} = Todos.create_item(%{content: "Test Item", list_id: list.id})
      update_attrs = %{content: "Updated Item", completed: true, position: 43}

      assert {:ok, %Item{} = item} = Todos.update_item(item, update_attrs)
      assert item.content == "Updated Item"
      assert item.completed == true
      assert item.position == 43
    end

    test "update_item/2 with invalid data returns error changeset", %{list: list} do
      {:ok, item} = Todos.create_item(%{content: "Test Item", list_id: list.id})
      assert {:error, %Ecto.Changeset{}} = Todos.update_item(item, %{content: nil})
      assert item == Todos.get_item!(item.id)
    end

    test "delete_item/1 deletes the item", %{list: list} do
      {:ok, item} = Todos.create_item(%{content: "Test Item", list_id: list.id})
      assert {:ok, %Item{}} = Todos.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_item!(item.id) end
    end
  end
end
