defmodule TodolistWeb.Lists.IndexLive do
  use TodolistWeb, :live_view
  alias Todolist.Todos

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns[:current_user] do
      lists = Todos.list_lists(socket.assigns.current_user)
      {:ok, assign(socket, lists: lists, new_list_title: "")}
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_event("create_list", %{"title" => title}, socket) do
    case Todos.create_list(socket.assigns.current_user, %{title: title}) do
      {:ok, _list} ->
        lists = Todos.list_lists(socket.assigns.current_user)
        {:noreply,
         socket
         |> assign(lists: lists, new_list_title: "")
         |> put_flash(:info, "List created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating list: #{error_to_string(changeset)}")
         |> assign(new_list_title: title)}
    end
  end

  @impl true
  def handle_event("delete_list", %{"id" => id}, socket) do
    list = Todos.get_list!(id)

    if Todos.can_access_list?(socket.assigns.current_user, list) do
      case Todos.delete_list(list) do
        {:ok, _} ->
          lists = Todos.list_lists(socket.assigns.current_user)
          {:noreply,
           socket
           |> assign(lists: lists)
           |> put_flash(:info, "List deleted successfully")}

        {:error, _} ->
          {:noreply,
           socket
           |> put_flash(:error, "Error deleting list")}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You don't have permission to delete this list")}
    end
  end

  @impl true
  def handle_event("share_list", %{"id" => id, "email" => email}, socket) do
    with %Todolist.Accounts.User{} = target_user <- Todolist.Accounts.get_user_by_email(email),
         %Todolist.Todos.List{} = list <- Todos.get_list!(id),
         true <- Todos.can_access_list?(socket.assigns.current_user, list),
         {:ok, _} <- Todos.share_list(list, target_user) do
      {:noreply,
       socket
       |> put_flash(:info, "List shared successfully")}
    else
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "User not found")}
      false ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to share this list")}
      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error sharing list")}
    end
  end

  @impl true
  def handle_event("validate_list", %{"title" => title}, socket) do
    {:noreply, assign(socket, new_list_title: title)}
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
