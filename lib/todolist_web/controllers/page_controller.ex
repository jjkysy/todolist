defmodule TodolistWeb.PageController do
  use TodolistWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
