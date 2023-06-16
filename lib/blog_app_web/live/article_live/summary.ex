defmodule BlogAppWeb.ArticleLive.Summary do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles

  def render(assigns) do
    ~H"""
    <.header>
      Listing Articles
    </.header>

    <div class="my-5">
      <.simple_form for={@form} phx-change="search_articles">
        <.input
          field={@form["keyword"]}
          type="text"
          placeholder="Search articles"
        />
      </.simple_form>
    </div>

    <div :for={article <- @articles} class="mt-2 border-2 rounded-lg py-2 px-4 cursor-pointer">
      <a href={~p"/accounts/profile/#{article.account_id}"} class="hover:underline">
        <%= article.account.name %>
      </a>
      <a href={~p"/articles/show/#{article.id}"}>
        <div class="text-gray-600 text-xs"><%= article.submit_date %></div>
        <h2 class="my-2 font-bold text-2xl hover:underline"><%= article.title %></h2>
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
      |> assign_form()

    {:ok, socket}
  end

  def handle_event("search_articles", %{"search_article" => %{"keyword" => keyword}}, socket) do
    socket =
      socket
      |> assign(:articles, Articles.search_articles_by_keyword(keyword))
      |> assign_form()

    {:noreply, socket}
  end

  defp assign_form(socket) do
    assign(socket, :form, to_form(%{}, as: "search_article"))
  end
end
