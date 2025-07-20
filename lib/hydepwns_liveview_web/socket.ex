defmodule HydepwnsLiveviewWeb.Socket do
  use Phoenix.Socket

  @sandbox_enabled Application.compile_env(:hydepwns_liveview, :sql_sandbox, false)

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # channel "room:*", HydepwnsLiveviewWeb.RoomChannel

  ## LiveView Topics
  # LiveView topics are handled automatically by Phoenix.LiveView
  # No explicit channel configuration needed for "lv:*" topics

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error` or `:error={:reason, term}`.
  # To control the response, return `{:ok, socket, response}`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(params, socket, connect_info) do
    # Enhanced connection handling for test environment
    if Mix.env() == :test do
      # In test mode, handle sandbox connections more robustly
      case handle_test_connection(params, socket, connect_info) do
        {:ok, socket} -> {:ok, socket}
        {:error, reason} -> {:error, reason}
      end
    else
      # In production/development, allow all connections
      {:ok, socket}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.HydepwnsLiveviewWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil

  # Private Functions

  defp handle_test_connection(_params, socket, connect_info) do
    # Extract session and cookies from connect_info
    session = Map.get(connect_info, :session, %{})
    cookies = Map.get(connect_info, :cookies, %{})

    # Check for sandbox cookie in both session and cookies
    sandbox_cookie = Map.get(session, "_phoenix_liveview_sandbox") ||
                    Map.get(cookies, "_phoenix_liveview_sandbox")

    if sandbox_cookie do
      # Try to join the sandbox
      case join_sandbox(sandbox_cookie) do
        :ok ->
          {:ok, socket}
        {:error, reason} ->
          {:error, reason}
      end
    else
      # No sandbox cookie, but still allow connection in test mode
      {:ok, socket}
    end
  end

  defp join_sandbox(sandbox_pid_str) when is_binary(sandbox_pid_str) do
    try do
      # Parse the PID string more robustly
      case parse_sandbox_pid(sandbox_pid_str) do
        {:ok, pid} ->
          # Allow the current process to use the sandbox
          case Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid) do
            :ok -> :ok
            {:error, reason} -> {:error, reason}
          end
        {:error, reason} ->
          {:error, reason}
      end
    rescue
      e ->
        {:error, "Failed to join sandbox: #{inspect(e)}"}
    end
  end

  defp join_sandbox(_), do: {:error, "Invalid sandbox PID format"}

  defp parse_sandbox_pid(pid_str) do
    # Handle different PID formats
    cond do
      # Format: "#PID<0.123.0>"
      Regex.match?(~r/#PID<(\d+)\.(\d+)\.(\d+)>/, pid_str) ->
        case Regex.run(~r/#PID<(\d+)\.(\d+)\.(\d+)>/, pid_str) do
          [_, node_id, process_id, serial] ->
            try do
              pid_str_parsed = "<#{node_id}.#{process_id}.#{serial}>"
              pid = :erlang.list_to_pid(String.to_charlist(pid_str_parsed))
              {:ok, pid}
            rescue
              _ -> {:error, "Failed to parse PID: #{pid_str}"}
            end
          _ ->
            {:error, "Invalid PID format: #{pid_str}"}
        end

      # Format: "<0.123.0>"
      Regex.match?(~r/<(\d+)\.(\d+)\.(\d+)>/, pid_str) ->
        case Regex.run(~r/<(\d+)\.(\d+)\.(\d+)>/, pid_str) do
          [_, node_id, process_id, serial] ->
            try do
              pid_str_parsed = "<#{node_id}.#{process_id}.#{serial}>"
              pid = :erlang.list_to_pid(String.to_charlist(pid_str_parsed))
              {:ok, pid}
            rescue
              _ -> {:error, "Failed to parse PID: #{pid_str}"}
            end
          _ ->
            {:error, "Invalid PID format: #{pid_str}"}
        end

      # Try direct evaluation as fallback (less secure but sometimes needed)
      true ->
        try do
          {pid, _} = Code.eval_string(pid_str)
          if is_pid(pid), do: {:ok, pid}, else: {:error, "Not a PID: #{pid_str}"}
        rescue
          _ -> {:error, "Failed to evaluate PID: #{pid_str}"}
        end
    end
  end
end
