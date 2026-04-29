defmodule ApiFromElixirMentor.Tasks do
  @moduledoc """
  The Tasks context.
  """

  alias ApiFromElixirMentor.Repo
  alias ApiFromElixirMentor.Tasks.Task
  import Ecto.Query

  @statuses Ecto.Enum.values(Task, :status)
  @types Ecto.Enum.values(Task, :type)
  @priorities Ecto.Enum.values(Task, :priority)

  def list_tasks(params) do
    Task
    |> filter_by_status(params["status"])
    |> filter_by_type(params["type"])
    |> filter_by_priority(params["priority"])
    |> order_by(desc: :priority, desc: :created_at, desc: :id)
    |> Repo.all()
  end

  def get_task!(id), do: Repo.get!(Task, id)

  defp filter_by_status(query, status) when status in @statuses do
    where(query, [t], t.status == ^status)
  end

  defp filter_by_status(query, _status), do: query

  defp filter_by_type(query, type) when type in @types do
    where(query, [t], t.type == ^type)
  end

  defp filter_by_type(query, _type), do: query

  defp filter_by_priority(query, priority) when priority in @priorities do
    where(query, [t], t.priority == ^priority)
  end

  defp filter_by_priority(query, _priority), do: query

  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end
end
