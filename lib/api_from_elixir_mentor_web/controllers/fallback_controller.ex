defmodule ApiFromElixirMentorWeb.FallbackController do
  use ApiFromElixirMentorWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ApiFromElixirMentorWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: MyApiWeb.ErrorHTML, json: MyApiWeb.ErrorJSON)
    |> render(:"404")
  end
end
