defmodule TodolistWeb.TodoItemsLive do
  use TodolistWeb, :live_view
  alias Todolist.Todos

  @impl true
  def mount(%{"id" => list_id}, _session, socket) do
    if socket.assigns[:current_user] do
      list = Todos.get_list!(list_id)

      if Todos.can_access_list?(socket.assigns.current_user, list) do
        items = Todos.list_items(list)
        {:ok,
         assign(socket,
           list: list,
           items: items,
           new_item_content: ""
         )}
      else
        {:ok,
         socket
         |> put_flash(:error, "You don't have permission to access this list")
         |> redirect(to: ~p"/lists")}
      end
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_event("create_item", %{"content" => content}, socket) do
    if Todos.can_access_list?(socket.assigns.current_user, socket.assigns.list) do
      case Todos.create_item(%{content: content, list_id: socket.assigns.list.id}) do
        {:ok, _item} ->
          items = Todos.list_items(socket.assigns.list)
          {:noreply,
           socket
           |> assign(items: items, new_item_content: "")
           |> put_flash(:info, "Item added successfully")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Error adding item: #{error_to_string(changeset)}")
           |> assign(new_item_content: content)}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You don't have permission to add items to this list")}
    end
  end

  @impl true
  def handle_event("toggle_item", %{"id" => id}, socket) do
    item = Todos.get_item!(id)
    if Todos.can_access_list?(socket.assigns.current_user, socket.assigns.list) do
      case Todos.update_item(item, %{completed: !item.completed}) do
        {:ok, _item} ->
          items = Todos.list_items(socket.assigns.list)
          {:noreply, assign(socket, items: items)}

        {:error, _changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Error updating item")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You don't have permission to update items in this list")}
    end
  end

  @impl true
  def handle_event("delete_item", %{"id" => id}, socket) do
    item = Todos.get_item!(id)
    if Todos.can_access_list?(socket.assigns.current_user, socket.assigns.list) do
      case Todos.delete_item(item) do
        {:ok, _} ->
          items = Todos.list_items(socket.assigns.list)
          {:noreply,
           socket
           |> assign(items: items)
           |> put_flash(:info, "Item deleted successfully")}

        {:error, _} ->
          {:noreply,
           socket
           |> put_flash(:error, "Error deleting item")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You don't have permission to delete items from this list")}
    end
  end

  @impl true
  def handle_event("validate_item", %{"content" => content}, socket) do
    {:noreply, assign(socket, new_item_content: content)}
  end

  defp error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k} #{v}" end)
    |> Enum.join(", ")
  end
end
