defmodule HydepwnsLiveview.Events.DeliveryService do
  @moduledoc """
  Manages delivery of reminders through various channels.
  Supports multiple delivery methods and can be easily extended.
  """

  alias HydepwnsLiveview.Events.CryptoService

  @type delivery_type :: :email | :sms | :push | :webhook
  @type delivery_result :: {:ok, String.t()} | {:error, String.t()}

  @doc """
  Sends a reminder through the specified delivery method.
  Returns {:ok, message} on success or {:error, reason} on failure.
  """
  @spec send_reminder(struct(), delivery_type(), map()) :: delivery_result()
  def send_reminder(reminder, delivery_type, settings) do
    with {:ok, adapter} <- get_adapter(delivery_type),
         {:ok, config} <- get_config(delivery_type),
         {:ok, encrypted_message} <- CryptoService.encrypt_message(reminder, settings) do
      adapter.send_reminder(reminder, settings, config, encrypted_message)
    end
  end

  @doc """
  Sends a reminder through multiple delivery methods.
  Returns a map of results for each delivery method.
  """
  @spec send_reminder_multi(struct(), [delivery_type()], map()) :: %{delivery_type() => delivery_result()}
  def send_reminder_multi(reminder, delivery_types, settings) do
    delivery_types
    |> Enum.map(fn type -> {type, send_reminder(reminder, type, settings)} end)
    |> Map.new()
  end

  # Private functions

  defp get_adapter(:email), do: {:ok, HydepwnsLiveview.Events.Adapters.EmailAdapter}
  defp get_adapter(:sms), do: {:ok, HydepwnsLiveview.Events.Adapters.SMSAdapter}
  defp get_adapter(:push), do: {:ok, HydepwnsLiveview.Events.Adapters.PushAdapter}
  defp get_adapter(:webhook), do: {:ok, HydepwnsLiveview.Events.Adapters.WebhookAdapter}
  defp get_adapter(_), do: {:error, "Unsupported delivery type"}

  defp get_config(delivery_type) do
    config = Application.get_env(:hydepwns_liveview, :reminder_services)
    case config[delivery_type] do
      nil -> {:error, "No configuration found for #{delivery_type}"}
      config -> {:ok, config}
    end
  end
end 