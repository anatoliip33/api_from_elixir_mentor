defmodule ApiFromElixirMentorWeb.TaskControllerTest do
  use ApiFromElixirMentorWeb.ConnCase, async: true

  alias ApiFromElixirMentor.Repo
  alias ApiFromElixirMentor.Tasks.Task

  describe "POST /api/tasks" do
    test "creates a queued task", %{conn: conn} do
      params = %{
        "title" => "Import customers",
        "type" => "import",
        "priority" => "critical",
        "payload" => %{"source" => "s3://bucket/customers.csv"},
        "max_attempts" => 5,
        "status" => "completed"
      }

      conn = post(conn, ~p"/api/tasks", params)

      assert %{
               "id" => id,
               "title" => "Import customers",
               "type" => "import",
               "priority" => "critical",
               "payload" => %{"source" => "s3://bucket/customers.csv"},
               "max_attempts" => 5,
               "status" => "queued",
               "created_at" => _
             } = json_response(conn, 201)["data"]

      task = Repo.get!(Task, id)
      assert task.status == :queued
      assert task.priority == :critical
    end

    test "returns validation errors", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", %{"title" => "Missing fields"})

      assert %{
               "type" => ["can't be blank"],
               "priority" => ["can't be blank"],
               "payload" => ["can't be blank"]
             } = json_response(conn, 422)["errors"]
    end
  end
end
