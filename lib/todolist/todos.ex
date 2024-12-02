defmodule Todolist.Todos do
  import Ecto.Query, warn: false
  alias Todolist.Repo
  alias Todolist.Todos.{List, Item}
  alias Todolist.Accounts.User

  # Lists
  def create_list(attrs \\ %{})

  def create_list(attrs) when is_map(attrs) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  def create_list(%User{} = user, attrs) do
    user
    |> Ecto.build_assoc(:lists, as: :owner)
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  def get_list!(id), do: Repo.get!(List, id)

  def get_user_list!(user_id, id) do
    List
    |> where([l], l.owner_id == ^user_id)
    |> where([l], l.id == ^id)
    |> Repo.one!()
  end

  def list_lists(%User{} = user) do
    user = Repo.preload(user, [:lists, :shared_lists])
    user.lists ++ user.shared_lists
  end

  def list_lists(user_id) do
    List
    |> where(owner_id: ^user_id)
    |> Repo.all()
  end

  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  # Items
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def list_items(%List{} = list) do
    from(i in Item,
      where: i.list_id == ^list.id,
      order_by: [asc: i.position]
    )
    |> Repo.all()
  end

  def list_items(list_id) do
    Item
    |> where(list_id: ^list_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  # Shares
  def share_list(%List{} = list, %User{} = target_user) do
    Repo.insert_all("user_lists", [
      %{
        list_id: list.id,
        user_id: target_user.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    ])
  end

  def unshare_list(%List{} = list, %User{} = target_user) do
    Repo.delete_all(
      from(ul in "user_lists",
        where: ul.list_id == ^list.id and ul.user_id == ^target_user.id
      )
    )
  end

  def list_shared_users(%List{} = list) do
    list
    |> Repo.preload(:shared_users)
    |> Map.get(:shared_users)
  end

  def can_access_list?(%User{} = user, %List{} = list) do
    list.owner_id == user.id or
      Repo.exists?(
        from(ul in "user_lists",
          where: ul.list_id == ^list.id and ul.user_id == ^user.id
        )
      )
  end
end
