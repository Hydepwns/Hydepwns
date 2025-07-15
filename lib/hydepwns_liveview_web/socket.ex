defmodule HydepwnsLiveviewWeb.Socket do
  use Phoenix.Socket

  @sandbox_enabled Application.compile_env(:hydepwns_liveview, :sql_sandbox, false)

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # channel "room:*", HydepwnsLiveviewWeb.RoomChannel

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
  def connect(_params, socket, connect_info) do
    # Handle sandbox connection for tests
    if @sandbox_enabled do
      cookies = connect_info[:cookies]
      session = connect_info[:session] || %{}
      IO.puts("[debug] [Socket] connect_info[:cookies]: #{inspect(cookies)}")
      IO.puts("[debug] [Socket] Full connect_info keys: #{inspect(Map.keys(connect_info))}")
      IO.puts("[debug] [Socket] connect_info[:conn]: #{inspect(connect_info[:conn])}")
      IO.puts("[debug] [Socket] Session keys: #{inspect(Map.keys(session))}")

      sandbox_cookie =
        case cookies do
          :all ->
            # When cookies is :all, we need to access the raw cookies
            # This is a workaround for the sandbox cookie issue
            case connect_info[:conn] do
              %{req_cookies: req_cookies} when is_map(req_cookies) ->
                IO.puts("[debug] [Socket] Found req_cookies: #{inspect(req_cookies)}")
                req_cookies["_phoenix_liveview_sandbox"]
              conn when not is_nil(conn) ->
                IO.puts("[debug] [Socket] Conn exists but no req_cookies: #{inspect(conn)}")
                nil
              _ ->
                IO.puts("[debug] [Socket] No conn in connect_info")
                nil
            end
          cookies when is_map(cookies) ->
            # Try both string and atom keys
            cookies["_phoenix_liveview_sandbox"] || cookies[:_phoenix_liveview_sandbox]
          _ -> nil
        end

      # Also check session for sandbox PID
      sandbox_pid = sandbox_cookie || session["_phoenix_liveview_sandbox"]

      case sandbox_pid do
        nil ->
          IO.puts("[debug] [Socket] No sandbox cookie found, cannot join sandbox")
          {:ok, socket}

        sandbox_pid_string ->
          IO.puts("[debug] [Socket] Found sandbox cookie: #{inspect(sandbox_pid_string)}")
          case Code.eval_string(sandbox_pid_string) do
            {pid, _} when is_pid(pid) ->
              IO.puts("[debug] [Socket] Joining sandbox: #{inspect(pid)}")
              Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)
              {:ok, socket}

            _ ->
              IO.puts("[debug] [Socket] Invalid sandbox PID: #{sandbox_pid_string}")
              {:ok, socket}
          end
      end
    else
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
end
