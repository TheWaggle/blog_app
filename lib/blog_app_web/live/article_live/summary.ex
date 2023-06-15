defmodule BlogAppWeb.ArticleLive.Summary do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles

  def render(assigns) do
    ~H"""
    <.header>
      Listing Articles
    </.header>

    <div :for={article <- @articles} class="mt-2">
      <a href={~p"/articles/show/#{article.id}"}>
        <div><%= article.account.name %></div>
        <div><%= article.submit_date %></div>
        <h2><%= article.title %></h2>
        <div>Liked：<%= Enum.count(article.likes) %></div>
      </a>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:articles, Articles.list_articles())
      |> assign(:page_title, "blog")

    {:ok, socket}
  end
end
