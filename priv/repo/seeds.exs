alias TaskPipeline.Tasks
alias TaskPipeline.Tasks.Task, as: TaskContext

IO.puts("Seeding database with sample tasks...")

for task <- 1..10 do
  Task.async(fn ->
    Tasks.create_task(%{
      title: "Task #{task}",
      type: Ecto.Enum.values(TaskContext, :type) |> Enum.random(),
      priority: Ecto.Enum.values(TaskContext, :priority) |> Enum.random(),
      status: Ecto.Enum.values(TaskContext, :status) |> Enum.random(),
      payload: %{},
      max_attempts: Enum.random(1..3)
    })
  end)
end
|> Enum.each(&Task.await/1)
