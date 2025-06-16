# defmodule HydepwnsLiveview.Notifications.MessageBird do
#   @moduledoc """
#   MessageBird integration for sending SMS notifications.
#   """

#   @doc """
#   Creates a MessageBird client with the given API key.
#   """
#   def client(api_key) when is_binary(api_key) and byte_size(api_key) > 0 do
#     %{
#       api_key: api_key,
#       base_url: "https://rest.messagebird.com"
#     }
#   end
#   def client(_invalid_api_key), do: {:error, :invalid_api_key}

#   @doc """
#   Creates and sends an SMS message using MessageBird.
#   """
#   def message_create(client, params) when is_map(client) and is_map(params) do
#     with {:ok, _} <- validate_client(client),
#          {:ok, _} <- validate_params(params) do
#       url = "#{client.base_url}/messages"
#       headers = [
#         {"Authorization", "AccessKey #{client.api_key}"},
#         {"Content-Type", "application/json"}
#       ]

#       body = Jason.encode!(params)

#       case HTTPoison.post(url, body, headers) do
#         {:ok, %{status_code: 200, body: body}} ->
#           {:ok, Jason.decode!(body)}

#         {:ok, %{status_code: status_code, body: body}} ->
#           {:error, %{status_code: status_code, body: Jason.decode!(body)}}

#         {:error, %HTTPoison.Error{reason: reason}} ->
#           {:error, %{reason: reason}}
#       end
#     end
#   end
#   def message_create(_invalid_client, _invalid_params), do: {:error, :invalid_parameters}

#   # Private functions

#   defp validate_client(%{api_key: api_key, base_url: base_url})
#        when is_binary(api_key) and byte_size(api_key) > 0
#        and is_binary(base_url) and byte_size(base_url) > 0 do
#     :ok
#   end
#   defp validate_client(_invalid_client), do: {:error, :invalid_client}

#   defp validate_params(%{originator: originator, recipients: recipients, body: body})
#        when is_binary(originator) and byte_size(originator) > 0
#        and is_list(recipients) and length(recipients) > 0
#        and is_binary(body) and byte_size(body) > 0 do
#     :ok
#   end
# end 