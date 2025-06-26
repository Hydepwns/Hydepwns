defmodule HydepwnsLiveviewWeb.TestResourceLive do
  use HydepwnsLiveviewWeb.BaseLive
  use HydepwnsLiveviewWeb.Resources.ResourceLive
  import HydepwnsLiveview.Utils.ResourceAssigns

  assigns_resource do
    attributes do
      import HydepwnsLiveview.Utils.ResourceAssigns, only: [attribute: 3, nested_attribute: 4]
      attribute(:page_title, :string, default: "Test Resource")

      nested_attribute :user, :map, [default: %{id: nil, name: "Test User", role: "user"}] do
        attribute(:id, :string, required: true)
        attribute(:name, :string, default: "Test User")
        attribute(:role, {:one_of, ["admin", "user", "guest"]}, default: "user")
      end

      attribute(:settings, :map, default: %{theme: "dark"})

      attribute(:items, {:list, :string}, default: [])
    end
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl Phoenix.LiveView
  def handle_event("update_role", %{"role" => role}, socket) do
    current_user = HydepwnsLiveview.Utils.LiveViewAPI.get_assign(socket, :user)
    updated_user = Map.put(current_user, :role, role)

    update_result = HydepwnsLiveview.Utils.LiveViewAPI.update(socket, :user, updated_user)

    case update_result do
      {:ok, updated_socket} ->
        {:noreply, updated_socket}

      {:error, message, error_socket} ->
        {:noreply, Phoenix.LiveView.put_flash(error_socket, :error, message)}
    end
  end

  # Added for testing LiveViewAPI.update
  @impl Phoenix.LiveView
  def handle_event("test_api_update", %{"field" => field, "value" => value}, socket) do
    updated_socket = apply_update(socket, field, value)
    {:noreply, updated_socket}
  end

  defp apply_update(socket, field_string, value, opts \\ []) do
    field = String.to_atom(field_string)

    case HydepwnsLiveview.Utils.LiveViewAPI.update_field(socket, field, value, opts) do
      {:ok, updated_socket} -> updated_socket
      {:error, _message, error_socket} -> error_socket
    end
  end

  defp process_settings(settings) do
    case settings do
      {:%{}, _meta, keyword_list_data} when is_list(keyword_list_data) ->
        Enum.into(keyword_list_data, %{})

      plain_map when is_map(plain_map) ->
        plain_map

      _ ->
        %{}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    assigns = Map.put(assigns, :settings, process_settings(assigns.settings))

    ~H"""
    <div id="test-resource">
      <h1>{@page_title}</h1>

      <div id="user-info">
        <div id="user-id">{@user.id}</div>
        <div id="user-name">{@user.name}</div>
        <div id="user-role">{@user.role}</div>
      </div>

      <div id="settings">
        <div id="theme">{Map.get(@settings, :theme)}</div>
      </div>

      <div id="items">
        <%= for item <- @items do %>
          <div class="item">{item}</div>
        <% end %>
      </div>

      <button id="set-admin" phx-click="update_role" phx-value-role="admin">Set Admin</button>
      <button id="set-guest" phx-click="update_role" phx-value-role="guest">Set Guest</button>
    </div>
    """
  end

  def do_mount(_params, _session, socket) do
    socket = init_resource_assigns(socket)
    socket
  end
end 