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
end
