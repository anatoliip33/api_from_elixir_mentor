defmodule ApiFromElixirMentorWeb.TaskController do
  use ApiFromElixirMentorWeb, :controller

  alias ApiFromElixirMentor.Tasks

  action_fallback ApiFromElixirMentorWeb.FallbackController

  def index(conn, params) do
    tasks = Tasks.list_tasks(params)

    render(conn, :index, tasks: tasks)
  end

  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    render(conn, :show, task: task)
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, task} <- Tasks.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/tasks/#{task}")
      |> render(:show, task: task)
    end
  end
end
