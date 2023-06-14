defmodule BlogApp.Articles do
  import Ecto.Query
  alias BlogApp.Repo
  alias BlogApp.Articles.Article

  def list_articles() do
    Article
    |> where([a], a.status == 1)
    |> preload(:account)
    |> Repo.all
  end

  def get_article!(id) do
    Article
    |> where([a], a.id == ^id)
    |> preload(:account)
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
end