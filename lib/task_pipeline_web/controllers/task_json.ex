defmodule TaskPipelineWeb.TaskJSON do
  alias TaskPipeline.Tasks.Task

  @doc """
  Renders a list of tasks.
  """
  def index(%{tasks: tasks, next_cursor: next_cursor}) do
    %{data: for(task <- tasks, do: data(task)), next_cursor: next_cursor}
  end

  @doc """
  Renders a single task.
  """
  def show(%{task: task}) do
    data(task)
  end

  def summary(%{tasks_summary: tasks_summary}) do
    tasks_summary
  end

  defp data(%Task{} = task) do
    %{
      id: task.id,
      title: task.title,
      type: task.type,
      priority: task.priority,
      payload: task.payload,
      max_attempts: task.max_attempts,
      status: task.status,
      created_at: task.created_at
    }
  end
end
