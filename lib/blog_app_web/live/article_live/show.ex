defmodule BlogAppWeb.ArticleLive.Show do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles
  alias BlogApp.Articles.Comment

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

    <div class="mt-4">
      <h3>コメント</h3>
      <div :for={comment <- @article.comments} class="mt-2 border-b">
        <a><%= comment.account.name %></a>
        <div><%= Calendar.strftime(comment.inserted_at, "%c") %></div>
        <div><%= comment.body %></div>
      </div>
      <.simple_form
        for={@form}
        phx-change="comment_validate"
        phx-submit="comment_save"
        :if={@current_account_id != @article.account_id and @current_account}
      >
        <.input field={@form[:body]} type="textarea" placeholder="Enter a comment" />
        <:actions>
          <.button phx-disabled-with="submitting...">Submit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"article_id" => article_id}, _uri, socket) do
    article = Articles.get_article!(article_id)

    socket =
      unless article.status == 0 do
        current_account_id =
          Map.get(socket.assigns.current_account || %{}, :id)

        socket
        |> assign(:article, article)
        |> assign_form(Articles.change_comment(%Comment{}))
        |> assign(:current_account_id, current_account_id)
        |> assign(:page_title, article.title)
      else
        redirect(socket, to: ~p"/")
      end

    {:noreply, socket}
  end

  def handle_event("comment_validate", %{"comment" => params}, socket) do
    cs = Articles.change_comment(%Comment{}, params)

    {:noreply, assign_form(socket, cs)}
  end

  def handle_event("comment_save", %{"comment" => params}, socket) do
    params =
      Map.merge(
        params,
        %{
          "account_id" => socket.assigns.current_account.id,
          "article_id" => socket.assigns.article.id
        }
      )

    socket =
      case Articles.create_comment(params) do
        {:ok, _comment} ->
          socket
          |> put_flash(:info, "Comment created successfully.")
          |> assign(:article, Articles.get_article!(socket.assigns.article.id))
          |> assign_form(Articles.change_comment(%Comment{}))

        {:error, cs} ->
          assign_form(socket, cs)
      end

    {:noreply, socket}
  end

  defp assign_form(socket, cs) do
    assign(socket, :form, to_form(cs))
  end
end
