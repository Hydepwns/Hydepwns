ExUnit.start()
{:ok, _} = Application.ensure_all_started(:hydepwns_liveview)
Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)

{:ok, _} =
  case HydepwnsLiveview.Resources.ResourceSystem.start_link() do
    {:ok, pid} -> {:ok, pid}
    {:error, {:already_started, _pid}} -> {:ok, :already_started}
  end
