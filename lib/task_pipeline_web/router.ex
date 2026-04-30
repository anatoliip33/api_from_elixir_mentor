defmodule TaskPipelineWeb.Router do
  use TaskPipelineWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TaskPipelineWeb do
    pipe_through :api

    get "/tasks/summary", TaskController, :summary

    resources "/tasks", TaskController, only: [:index, :show, :create]
  end
end
