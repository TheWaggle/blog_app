defmodule BlogAppWeb.ArticleLive.Show do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles

  def render(assigns) do
    ~H"""
    <div :if={@article.status == 2}>
      This is a limited article.
    </div>

    <div>
      <a><%= @article.account.name %></a>
      <div><%= @article.submit_date %></div>
      <h2><%= @article.title %></h2>
      <div><%= @article.body %></div>
    </div>
    """
  end

  def mount(%{"article_id" => article_id}, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"article_id" => article_id}, _uri, socket) do
    article = Articles.get_article!(article_id)

    socket =
      unless article.status == 0 do
        socket
        |> assign(:article, article)
        |> assign(:page_title, article.title)
      else
        redirect(socket, to: ~p"/")
      end

    {:noreply, socket}
  end
end
