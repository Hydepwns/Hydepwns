defmodule HydepwnsLiveviewWeb.Presence do
  use Phoenix.Presence,
    otp_app: :hydepwns_liveview,
    pubsub_server: HydepwnsLiveview.PubSub

  def broadcast_to_users(topic, event, payload, user_ids) do
    Enum.each(user_ids, fn user_id ->
      Phoenix.PubSub.broadcast(
        HydepwnsLiveview.PubSub,
        "user:#{user_id}",
        {event, payload}
      )
    end)
  end
end
