defmodule TaskPipelineWeb.TaskController do
  use TaskPipelineWeb, :controller

  alias TaskPipeline.Tasks

  action_fallback TaskPipelineWeb.FallbackController

  def index(conn, params) do
    {tasks, next} = Tasks.list_tasks(params)

    render(conn, :index, tasks: tasks, next_cursor: next)
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

  def summary(conn, _params) do
    tasks_summary = Tasks.get_summary()

    render(conn, :summary, tasks_summary: tasks_summary)
  end
end
