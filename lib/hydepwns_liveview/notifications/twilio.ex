defmodule HydepwnsLiveview.Notifications.Twilio do
  @moduledoc """
  Twilio integration for sending SMS notifications.
  """

  @doc """
  Creates a Twilio client with the given account SID and auth token.
  """
  def client(account_sid, auth_token) 
      when is_binary(account_sid) and byte_size(account_sid) > 0
      and is_binary(auth_token) and byte_size(auth_token) > 0 do
    %{
      account_sid: account_sid,
      auth_token: auth_token,
      base_url: "https://api.twilio.com/2010-04-01/Accounts/#{account_sid}"
    }
  end
  def client(_invalid_account_sid, _invalid_auth_token), do: {:error, :invalid_credentials}

  @doc """
  Creates and sends an SMS message using Twilio.
  """
  def message_create(client, params) when is_map(client) and is_map(params) do
    with {:ok, _} <- validate_client(client),
         {:ok, _} <- validate_params(params) do
      url = "#{client.base_url}/Messages.json"
      auth = Base.encode64("#{client.account_sid}:#{client.auth_token}")
      headers = [
        {"Authorization", "Basic #{auth}"},
        {"Content-Type", "application/x-www-form-urlencoded"}
      ]

      body = URI.encode_query(params)

      case HTTPoison.post(url, body, headers) do
        {:ok, %{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}

        {:ok, %{status_code: status_code, body: body}} ->
          {:error, %{status_code: status_code, body: Jason.decode!(body)}}

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, %{reason: reason}}
      end
    end
  end
  def message_create(_invalid_client, _invalid_params), do: {:error, :invalid_parameters}

  # Private functions

  defp validate_client(%{account_sid: account_sid, auth_token: auth_token, base_url: base_url})
       when is_binary(account_sid) and byte_size(account_sid) > 0
       and is_binary(auth_token) and byte_size(auth_token) > 0
       and is_binary(base_url) and byte_size(base_url) > 0 do
    :ok
  end
  defp validate_client(_invalid_client), do: {:error, :invalid_client}

  defp validate_params(%{From: from, To: to, Body: body})
       when is_binary(from) and byte_size(from) > 0
       and is_binary(to) and byte_size(to) > 0
       and is_binary(body) and byte_size(body) > 0 do
    :ok
  end
  defp validate_params(_invalid_params), do: {:error, :invalid_params}
end 