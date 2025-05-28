defmodule HydepwnsLiveview.Events.Event do
  @moduledoc """
  Event module for handling resource events.
  """

  alias HydepwnsLiveview.Events.EventBus

  @doc """
  Creates a new event with the given type and data.
  """
  @spec create(String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(type, data) when is_binary(type) and is_map(data) do
    case HydepwnsLiveview.Events.Core.Event.create(type, data) do
      {:ok, event} ->
        case HydepwnsLiveview.Events.EventBus.publish(event) do
          :ok -> {:ok, event}
          error -> error
        end
      error -> error
    end
  end

  defp generate_event_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end
end
