defmodule ApiFromElixirMentorWeb.TaskJSON do
  alias ApiFromElixirMentor.Tasks.Task

  @doc """
  Renders a list of tasks.
  """
  def index(%{tasks: tasks}) do
    for(task <- tasks, do: data(task))
  end

  @doc """
  Renders a single task.
  """
  def show(%{task: task}) do
    data(task)
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
