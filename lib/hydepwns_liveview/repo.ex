defmodule HydepwnsLiveview.Repo do
  use Ecto.Repo,
    otp_app: :hydepwns_liveview,
    adapter: Ecto.Adapters.Postgres
end
