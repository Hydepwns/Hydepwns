defmodule HydepwnsLiveviewWeb.UserEmailChangeLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, User.email_change_changeset(socket.assigns.current_user, %{}))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> User.email_change_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.change_email(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Email change request sent. Please check your email for confirmation.")
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
        Change Email
        <:subtitle>Update your email address.</:subtitle>
      </.header>

      <.simple_form for={@changeset} id="user-email-change-form" phx-change="validate" phx-submit="save">
        <.input field={@changeset[:email]} type="email" label="New Email" />
        <.input field={@changeset[:current_password]} type="password" label="Current password" />
        <:actions>
          <.button phx-disable-with="Saving...">Change Email</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 