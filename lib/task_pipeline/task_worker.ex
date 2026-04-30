defmodule TaskPipeline.TaskWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias TaskPipeline.Tasks

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"task_id" => task_id}, attempt: attempt, max_attempts: max}) do
    task = Tasks.get_task!(task_id)

    # queued → processing
    Tasks.update_task(task, %{status: :processing})

    # Simulate work
    sleep_for(task.priority)

    if :rand.uniform() <= 0.2 do
      if attempt >= max do
        Tasks.update_task(task, %{status: :failed})

        {:error, :max_attempts_reached}
      else
        {:error, :retry}
      end
    else
      Tasks.update_task(task, %{status: :completed})
      :ok
    end
  end

  defp sleep_for(:critical), do: Process.sleep(Enum.random(1000..2000))
  defp sleep_for(:high), do: Process.sleep(Enum.random(2000..4000))
  defp sleep_for(:normal), do: Process.sleep(Enum.random(4000..6000))
  defp sleep_for(_), do: Process.sleep(Enum.random(6000..8000))
end
