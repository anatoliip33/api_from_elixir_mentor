defmodule ApiFromElixirMentor.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :type, Ecto.Enum, values: [:import, :export, :report, :cleanup]
    field :priority, Ecto.Enum, values: [low: 1, normal: 2, high: 3, critical: 4]
    field :payload, :map
    field :max_attempts, :integer, default: 3
    field :status, Ecto.Enum, values: [:queued, :processing, :completed, :failed]

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :type, :priority, :payload, :max_attempts, :status])
    |> validate_required([:title, :payload])
  end
end
