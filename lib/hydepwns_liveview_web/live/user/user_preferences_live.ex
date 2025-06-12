defmodule HydepwnsLiveviewWeb.UserPreferencesLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, User.preferences_changeset(socket.assigns.current_user, %{}))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> User.preferences_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user_preferences(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Preferences updated successfully")
         |> redirect(to: ~p"/users/preferences")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        User Preferences
        <:subtitle>Manage your user preferences.</:subtitle>
      </.header>

      <.simple_form for={@changeset} id="preferences-form" phx-change="validate" phx-submit="save">
        <.input field={@changeset[:theme]} type="select" label="Theme" options={[{"Light", "light"}, {"Dark", "dark"}, {"System", "system"}]} />
        <.input field={@changeset[:language]} type="select" label="Language" options={[{"English", "en"}, {"Spanish", "es"}, {"French", "fr"}]} />
        <.input field={@changeset[:notifications_enabled]} type="checkbox" label="Enable Notifications" />
        <.input field={@changeset[:email_notifications]} type="checkbox" label="Email Notifications" />
        <.input field={@changeset[:push_notifications]} type="checkbox" label="Push Notifications" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Preferences</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 