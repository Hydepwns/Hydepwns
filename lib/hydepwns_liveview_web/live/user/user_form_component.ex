defmodule HydepwnsLiveviewWeb.UserFormComponent do
  use HydepwnsLiveviewWeb, :live_component

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]
  import HydepwnsLiveviewWeb.CoreComponents

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user records.</:subtitle>
      </.header>

      <.simple_form
        for={@changeset}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@changeset[:name]} type="text" label="Name" />
        <.input field={@changeset[:email]} type="email" label="Email" />
        <.input field={@changeset[:password]} type="password" label="Password" />
        <.input field={@changeset[:password_confirmation]} type="password" label="Confirm password" />
        <.input field={@changeset[:role]} type="select" label="Role" options={[Admin: "admin", User: "user", Guest: "guest"]} />
        <.input field={@changeset[:bio]} type="textarea" label="Bio" />
        <.input field={@changeset[:avatar_url]} type="text" label="Avatar URL" />
        <.input field={@changeset[:metadata]} type="textarea" label="Metadata" />
        <.input field={@changeset[:tags]} type="text" label="Tags" />
        <.input field={@changeset[:categories]} type="text" label="Categories" />
        <.input field={@changeset[:active]} type="checkbox" label="Active" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 