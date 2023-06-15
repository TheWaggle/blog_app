defmodule BlogAppWeb.AccountPageLive do
  use BlogAppWeb, :live_view

  alias BlogApp.Accounts
  alias BlogApp.Articles

  def render(assigns) do
    ~H"""
    <div>
      <div><%= @account.name %></div>
      <div><%= @account.email %></div>
      <div><%= @account.introduction %></div>
      <div>Articles count：<%= @articles_count %></div>
      <div :if={@account.id == @current_account_id}>
        <a href={~p"/accounts/settings"}>Edit profile</a>
      </div>
    </div>

    <div>
      <div>
        <a href={~p"/accounts/profile/#{@account.id}"}>Articles</a>
      </div>

      <div>
        <%= if length(@articles) > 0 do %>
          <div :for={article <- @articles} class="mt-2">
            <a href={~p"/accounts/profile/#{article.account.id}"}>
              <%= article.account.name %>
            </a>
            <a href={~p"/articles/show/#{article.id}"}>
              <div><%= article.submit_date %></div>
              <h2><%= article.title %></h2>
              <div>Liked：<%= Enum.count(article.likes) %></div>
            </a>
          </div>
        <% else %>
          <div>
            No articles
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"account_id" => account_id}, _uri, socket) do
    socket =
      socket
      |> assign(:account, Accounts.get_account!(account_id))
      |> apply_action(socket.assigns.live_action)

    {:noreply, socket}
  end

  defp apply_action(socket, :info) do
    account = socket.assigns.account
    current_account = socket.assigns.current_account
    current_account_id = get_current_account_id(current_account)

    articles =
      Articles.list_articles_for_account(account.id, current_account_id)

    socket
    |> assign(:articles, articles)
    |> assign(:articles_count, Enum.count(articles))
    |> assign(:current_account_id, current_account_id)
    |> assign(:page_title, account.name)
  end

  defp get_current_account_id(current_account) do
    Map.get(current_account || %{}, :id)
  end
end
