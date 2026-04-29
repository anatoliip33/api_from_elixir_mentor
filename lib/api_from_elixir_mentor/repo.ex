defmodule ApiFromElixirMentor.Repo do
  use Ecto.Repo,
    otp_app: :api_from_elixir_mentor,
    adapter: Ecto.Adapters.Postgres
end
