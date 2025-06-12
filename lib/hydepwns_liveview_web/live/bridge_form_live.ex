defmodule HydepwnsLiveviewWeb.BridgeFormLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Bridge
  alias HydepwnsLiveview.Bridge.Models.Bridge

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, Bridge.changeset(%Bridge{}, %{}))}
  end

  @impl true
  def handle_event("validate", %{"bridge" => bridge_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Bridge.changeset(bridge_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"bridge" => bridge_params}, socket) do
    case Bridge.create_bridge(bridge_params) do
      {:ok, bridge} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bridge created successfully")
         |> redirect(to: ~p"/bridges/#{bridge}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Bridge Form
        <:subtitle>Create or edit a bridge.</:subtitle>
      </.header>

      <.simple_form for={@changeset} id="bridge-form" phx-change="validate" phx-submit="save">
        <.input field={@changeset[:name]} type="text" label="Name" />
        <.input field={@changeset[:description]} type="textarea" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Bridge</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 