defmodule HydepwnsLiveviewWeb.UserEmailConfirmationLive do
  use HydepwnsLiveviewWeb, :live_view

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    {:ok, assign(socket, :changeset, User.email_confirmation_changeset(%User{}, %{}, token))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> User.email_confirmation_changeset(user_params, socket.assigns.token)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.confirm_email(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Email confirmed successfully")
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
        Confirm Email
        <:subtitle>Confirm your new email address.</:subtitle>
      </.header>

      <.simple_form for={@changeset} id="email-confirmation-form" phx-change="validate" phx-submit="save">
        <.input field={@changeset[:email]} type="email" label="Email" />
        <:actions>
          <.button phx-disable-with="Confirming...">Confirm Email</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 