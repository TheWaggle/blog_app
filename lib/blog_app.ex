defmodule BlogApp do
  @moduledoc """
  BlogApp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  use Application

  def config_dir() do
    Path.join([Desktop.OS.home(), ".config", "blog_app"])
  end

  @app Mix.Project.config()[:app]
  def start(:normal, []) do
    File.mkdir_p!(config_dir())

    # DB
    {:ok, sup} = Supervisor.start_link([BlogApp.Repo], name: __MODULE__, strategy: :one_for_one)

    # PubSub Endpoint session
    {:ok, _} = Supervisor.start_child(sup, BlogAppWeb.Sup)

    # Desktop
    port = :ranch.get_port(BlogAppWeb.Endpoint.HTTP)
    {:ok, _} =
      Supervisor.start_child(sup, {
        Desktop.Window,
        [
          app: @app,
          id: BlogAppWindow,
          title: "BlogApp",
          size: {400, 800},
          url: "http://localhost:#{port}"
        ]
      })
  end
end
