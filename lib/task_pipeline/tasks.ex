defmodule TaskPipeline.Tasks do
  @moduledoc """
  The Tasks context.
  """

  alias TaskPipeline.Repo
  alias TaskPipeline.Tasks.Task
  import Ecto.Query

  @statuses Ecto.Enum.values(Task, :status)
  @types Ecto.Enum.values(Task, :type)
  @priorities Ecto.Enum.values(Task, :priority)

  def list_tasks(params) do
    cursor_params = %{
      cursor: params["next_cursor"],
      limit: String.to_integer(params["limit"] || "100"),
      max_limit: 100
    }

    %EctoCursor.Page{entries: entries, cursor: next_cursor} =
      Task
      |> filter_by_status(params["status"])
      |> filter_by_type(params["type"])
      |> filter_by_priority(params["priority"])
      |> filter_by_id(Integer.parse(params["before_id"] || ""))
      |> order_by(desc: :priority, desc: :created_at, desc: :id)
      |> Repo.paginate(cursor_params)

    {entries, next_cursor}
  end

  def get_task!(id), do: Repo.get!(Task, id)

  defp filter_by_id(query, :error), do: query
  defp filter_by_id(query, {id, _}), do: where(query, [t], t.id < ^id)

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

  def get_summary() do
    Task
    |> group_by([t], t.status)
    |> select([t], {t.status, count(t.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end
end
