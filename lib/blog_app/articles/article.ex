defmodule BlogApp.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias BlogApp.Accounts.Account

  schema "articles" do
    field :body, :string
    field :status, :integer, default: 1
    field :submit_date, :date
    field :title, :string
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body, :status, :submit_date, :account_id])
    |> validate_required([:title, :body, :status, :submit_date])
  end
end
