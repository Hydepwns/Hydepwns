defmodule HydepwnsLiveviewWeb.UserPasswordChangeLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, User.password_change_changeset(socket.assigns.current_user, %{}))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> User.password_change_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.change_password(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password changed successfully")
         |> redirect(to: ~p"/users/settings")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Change Password
        <:subtitle>Update your password.</:subtitle>
      </.header>

      <.simple_form for={@changeset} id="password-change-form" phx-change="validate" phx-submit="save">
        <.input field={@changeset[:current_password]} type="password" label="Current Password" />
        <.input field={@changeset[:password]} type="password" label="New Password" />
        <.input field={@changeset[:password_confirmation]} type="password" label="Confirm New Password" />
        <:actions>
          <.button phx-disable-with="Changing...">Change Password</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 