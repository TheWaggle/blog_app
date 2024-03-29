defmodule BlogAppWeb.AccountPageLive do
  use BlogAppWeb, :live_view

  alias BlogApp.Accounts
  alias BlogApp.Articles

  def render(assigns) do
    ~H"""
    <div class="border-2 rounded-lg px-2 py-4">
      <div class="font-bold font-lg"><%= @account.name %></div>
      <div class="text-gray-600 text-sm"><%= @account.email %></div>
      <div class="my-2 pb-2 whitespace-pre-wrap border-b"><%= @account.introduction %></div>
      <div>Articles count：<%= @articles_count %></div>
      <a
        href={~p"/accounts/settings"}
        class="mt-2 rounded-lg bg-gray-200 hover:bg-gray-400 py-1 px-4 block w-1/5 text-center"
        :if={@account.id == @current_account_id}
      >
        Edit profile
      </a>
    </div>

    <div>
      <div class="flex gap-2 items-center border-b-2 my-2">
        <a
          href={~p"/accounts/profile/#{@account.id}"}
          class={tabs_class(@live_action, :info)}
        >
          Articles
        </a>
        <a
          href={~p"/accounts/profile/#{@account.id}/draft"}
          class={tabs_class(@live_action, :draft)}
          :if={@account.id == @current_account_id}
        >
          Draft
        </a>
        <a
          href={~p"/accounts/profile/#{@account.id}/liked"}
          class={tabs_class(@live_action, :liked)}
        >
          Liked
        </a>
      </div>

      <div>
        <%= if length(@articles) > 0 do %>
          <div :for={article <- @articles} class="flex justify-between mt-2 pb-2 border-b last:border-none cursor-pointer">
            <div :if={@live_action in [:info, :liked]}>
              <a href={~p"/accounts/profile/#{article.account.id}"} class="hover:underline">
                <%= article.account.name %>
              </a>
              <a href={~p"/articles/show/#{article.id}"}>
                <div class="text-gray-600 text-xs"><%= article.submit_date %></div>
                <h2 class="my-2 font-bold text-2xl hover:underline"><%= article.title %></h2>
                <div>Liked：<%= Enum.count(article.likes) %></div>
              </a>
            </div>

            <div :if={@live_action == :draft}>
              <a href={~p"/articles/#{article.id}/edit"}>
                <h2 class="my-2 font-bold text-2xl hover:underline"><%= article.title %></h2>
                <div :if={article.body}><%= String.slice(article.body, 0..30) %></div>
              </a>
            </div>

            <div :if={@live_action in [:info, :draft]} class="relative">
              <div
                phx-click="set_article_id"
                phx-value-article_id={article.id}
                class="border rounded w-min px-1 mt-2"
                :if={@account.id == @current_account_id}
              >
                ...
              </div>
              <div
                class="absolute right-0 border rounded-lg py-2 px-2 mt-2 bg-white z-10"
                :if={article.id == @set_article_id}
              >
                <a href={~p"/articles/#{article.id}/edit"} class="block border-b pb-2">Edit</a>
                <span
                  phx-click="delete_article"
                  phx-value-article_id={article.id}
                  class="block mt-2 hover:underline"
                >
                  Delete
                </span>
              </div>
            </div>
          </div>
        <% else %>
          <div class="text-xl font-bold mt-2">
            <%=
              case @live_action do
                :info -> "No articles"
                :draft -> "No draft articles"
                :liked -> "No liked articles"
                _ -> ""
              end
            %>
          </div>
        <% end %>
      </div>
    </div>

    <.modal :if={@live_action in [:edit, :confirm_email]} id="account_settings" show on_cancel={JS.patch(~p"/accounts/profile/#{@account.id}")}>
      <.live_component
        module={BlogAppWeb.AccountSettingsComponent}
        id={@live_action}
        current_account={@current_account}
      />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"account_id" => account_id}, _uri, socket) do
    socket =
      socket
      |> assign(:account, Accounts.get_account!(account_id))
      |> assign(:set_article_id, nil)
      |> assign(:current_account_id, get_current_account_id(socket.assigns.current_account))
      |> apply_action(socket.assigns.live_action)

    {:noreply, socket}
  end

  def handle_params(%{"token" => token}, _uri, socket) do
    socket =
      case Accounts.update_account_email(socket.assigns.current_account, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
        end

    {:noreply, push_navigate(socket, to: ~p"/accounts/profile/#{socket.assigns.current_account.id}")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, apply_action(socket, :edit)}
  end

  defp apply_action(socket, :info) do
    account = socket.assigns.account
    current_account_id = socket.assigns.current_account_id

    articles =
      Articles.list_articles_for_account(account.id, current_account_id)

    socket
    |> assign(:articles, articles)
    |> assign(:articles_count, Enum.count(articles))
    |> assign(:page_title, account.name)
  end

  defp apply_action(socket, :draft) do
    account = socket.assigns.account
    current_account_id = socket.assigns.current_account_id

    if account.id == current_account_id do
      socket
      |> assign(:articles, Articles.list_draft_articles_for_account(current_account_id))
      |> assign_article_count(account.id, current_account_id)
      |> assign(:page_title, account.name <> " - draft")
    else
      redirect(socket, to: ~p"/accounts/profile/#{account.id}")
    end
  end

  defp apply_action(socket, :liked) do
    account = socket.assigns.account
    current_account_id = socket.assigns.current_account_id

    socket
    |> assign(:articles, Articles.list_liked_articles_for_account(account.id))
    |> assign_article_count(account.id, current_account_id)
    |> assign(:page_title, account.name <> " - liked")
  end

  defp apply_action(socket, :edit) do
    account = socket.assigns.current_account

    socket
    |> assign(:account, account)
    |> assign(:set_article_id, nil)
    |> assign(:current_account_id, account.id)
    |> assign(:articles, [])
    |> assign_article_count(account.id, account.id)
    |> assign(:page_title, "account settings")
  end

  defp get_current_account_id(current_account) do
    Map.get(current_account || %{}, :id)
  end

  defp assign_article_count(socket, account_id, current_account_id) do
    articles_count =
      account_id
      |> Articles.list_articles_for_account(current_account_id)
      |> Enum.count()

    assign(socket, :articles_count, articles_count)
  end

  def handle_info({:update_profile, account}, socket) do
    socket =
      socket
      |> put_flash(:info, "Account profile updated successfully")
      |> redirect(to: ~p"/accounts/profile/#{account.id}")

    {:noreply, socket}
  end

  def handle_info({:update_email, account}, socket) do
    socket =
      socket
      |> put_flash(:info, "A link to confirm your email change has been sent to the new address.")
      |> redirect(to: ~p"/accounts/profile/#{account.id}")

    {:noreply, socket}
  end

  def handle_event("set_article_id", %{"article_id" => article_id}, socket) do
    id =
      unless article_id == "#{socket.assigns.set_article_id}", do: String.to_integer(article_id), else: nil

    {:noreply, assign(socket, :set_article_id, id)}
  end

  def handle_event("delete_article", %{"article_id" => article_id}, socket) do
    socket =
      case Articles.delete_article(Articles.get_article!(article_id)) do
        {:ok, _article} ->
          assign_article_when_deleted(socket, socket.assigns.live_action)

        {:error, _cs} ->
          put_flash(socket, :error, "Could not article.")
      end

    {:noreply, socket}
  end

  defp assign_article_when_deleted(socket, :info) do
    articles =
      Articles.list_articles_for_account(socket.assigns.account.id, socket.assigns.current_account.id)

    socket
    |> assign(:articles, articles)
    |> assign(:articles_count, Enum.count(articles))
    |> put_flash(:info, "Article deleted successfully.")
  end

  defp assign_article_when_deleted(socket, :draft) do
    socket
    |> assign(:articles, Articles.list_draft_articles_for_account(socket.assigns.current_account.id))
    |> put_flash(:info, "Draft article deleted successfully.")
  end

  @tabs_class ~w(block rounded-t-lg px-2 py-2 text-xl)
  defp tabs_class(live_action, action) when live_action == action do
    Enum.join(@tabs_class ++ ~w(bg-gray-400), " ")
  end

  defp tabs_class(_live_action, _action) do
    Enum.join(@tabs_class ++ ~w(bg-gray-200 hover:bg-gray-400), " ")
  end
end
