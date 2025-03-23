defmodule AocVisualized.Repo do
  use Ecto.Repo,
    otp_app: :aoc_visualized,
    adapter: Ecto.Adapters.Postgres
end
