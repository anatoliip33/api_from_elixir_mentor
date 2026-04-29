defmodule ApiFromElixirMentorWeb.Router do
  use ApiFromElixirMentorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiFromElixirMentorWeb do
    pipe_through :api

    resources "/tasks", TaskController, only: [:index, :show, :create]
  end
end
