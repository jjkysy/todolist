# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Todolist.Repo
alias Todolist.Accounts
alias Todolist.Todos

# Clear existing data
Repo.delete_all("user_lists")
Repo.delete_all("items")
Repo.delete_all("lists")
Repo.delete_all("users")

# Create default users
{:ok, user1} = Accounts.register_user(%{
  email: "user1@example.com",
  password: "password123456"
})

{:ok, user2} = Accounts.register_user(%{
  email: "user2@example.com",
  password: "password123456"
})

# Create lists for user1
{:ok, shopping_list} = Todos.create_list(user1, %{
  title: "Shopping List"
})

{:ok, work_list} = Todos.create_list(user1, %{
  title: "Work Tasks"
})

{:ok, personal_list} = Todos.create_list(user1, %{
  title: "Personal Tasks"
})

# Create items for shopping list
shopping_items = [
  %{content: "Buy groceries", completed: false},
  %{content: "Get new shoes", completed: true},
  %{content: "Buy birthday gift", completed: false}
]

Enum.each(shopping_items, fn item ->
  Todos.create_item(shopping_list, item)
end)

# Create items for work list
work_items = [
  %{content: "Complete project proposal", completed: false},
  %{content: "Schedule team meeting", completed: true},
  %{content: "Review pull requests", completed: false},
  %{content: "Update documentation", completed: false}
]

Enum.each(work_items, fn item ->
  Todos.create_item(work_list, item)
end)

# Create items for personal list
personal_items = [
  %{content: "Go to gym", completed: true},
  %{content: "Read a book", completed: false},
  %{content: "Plan weekend trip", completed: false}
]

Enum.each(personal_items, fn item ->
  Todos.create_item(personal_list, item)
end)

# Create a list for user2 and share one of user1's lists
{:ok, user2_list} = Todos.create_list(user2, %{
  title: "My Tasks"
})

user2_items = [
  %{content: "Learn Elixir", completed: false},
  %{content: "Practice Phoenix", completed: false}
]

Enum.each(user2_items, fn item ->
  Todos.create_item(user2_list, item)
end)

# Share shopping list with user2
Todos.share_list(shopping_list, user2)

IO.puts """

Seeds planted successfully! 🌱

Default users created:
- Email: user1@example.com
- Email: user2@example.com
Password for both users: password123456

User1 has three lists:
- Shopping List (shared with user2)
- Work Tasks
- Personal Tasks

User2 has one list:
- My Tasks

You can now log in with either account to see the todo lists.
"""
