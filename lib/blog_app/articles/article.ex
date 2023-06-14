defmodule BlogApp.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias BlogApp.Accounts.Account

  schema "articles" do
    field :body, :string
    field :status, :integer, default: 0
    field :submit_date, :date
    field :title, :string
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body, :status, :submit_date, :account_id])
    |> validate_article()
  end

  defp validate_article(cs) do
    cs =
      validate_required(cs, :title, message: "Please fill in the title.")

    unless get_change(cs, :status, 0) == 0 do
      cs
      |> change(%{submit_date: Date.utc_today()})
      |> validate_required(:body, message: "Please fill in the body.")
      |> validate_required(:submit_date)
    else
      cs
    end
  end
end
