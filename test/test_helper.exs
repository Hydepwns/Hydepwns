ExUnit.start()
{:ok, _} = Application.ensure_all_started(:hydepwns_liveview)
Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)
