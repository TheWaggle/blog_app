defmodule BlogApp.Articles do
  import Ecto.Query
  alias BlogApp.Repo
  alias BlogApp.Articles.Article
  alias BlogApp.Articles.Comment

  def list_articles() do
    Article
    |> where([a], a.status == 1)
    |> preload([:account, :likes])
    |> Repo.all
  end

  def get_article!(id) do
    Article
    |> where([a], a.id == ^id)
    |> preload([:account, :likes, comments: [:account]])
    |> Repo.one()
  end

  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  # Comments

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
