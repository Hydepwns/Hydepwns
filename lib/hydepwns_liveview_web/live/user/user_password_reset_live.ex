defmodule HydepwnsLiveviewWeb.UserPasswordResetLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1, error: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, Accounts.change_user_password(%User{}, %{}))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully")
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
        Reset Password
        <:subtitle>Enter your new password.</:subtitle>
      </.header>

      <.simple_form for={@changeset} id="password-reset-form" phx-change="validate" phx-submit="save">
        <.error :if={@changeset.action}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@changeset[:password]} type="password" label="New Password" required />
        <.input field={@changeset[:password_confirmation]} type="password" label="Confirm New Password" required />

        <:actions>
          <.button phx-disable-with="Resetting password...">Reset Password</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 