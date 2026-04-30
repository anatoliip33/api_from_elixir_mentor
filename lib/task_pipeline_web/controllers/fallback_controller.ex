defmodule TaskPipelineWeb.FallbackController do
  use TaskPipelineWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: TaskPipelineWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: MyApiWeb.ErrorHTML, json: MyApiWeb.ErrorJSON)
    |> render(:"404")
  end
end
