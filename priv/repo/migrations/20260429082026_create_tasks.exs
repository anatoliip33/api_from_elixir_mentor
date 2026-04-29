defmodule ApiFromElixirMentor.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :type, :string
      add :priority, :integer
      add :payload, :map, null: false
      add :max_attempts, :integer, default: 3
      add :status, :string

      timestamps(inserted_at: :created_at, updated_at: false)
    end

    create index(
             :tasks,
             ["priority DESC", "created_at DESC", "id DESC"],
             name: :tasks_priority_created_at_id_desc_index
           )

    create index(
             :tasks,
             [:status, "priority DESC", "created_at DESC", "id DESC"],
             name: :tasks_status_priority_created_at_id_desc_index
           )

    create index(
             :tasks,
             [:type, "priority DESC", "created_at DESC", "id DESC"],
             name: :tasks_type_priority_created_at_id_desc_index
           )

    create index(
             :tasks,
             [:status, :type, "priority DESC", "created_at DESC", "id DESC"],
             name: :tasks_status_type_priority_created_at_id_desc_index
           )
  end
end
