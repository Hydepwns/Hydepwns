defmodule HydepwnsLiveviewWeb.UserFormLive do
  @moduledoc """
  LiveView for creating and editing users.
  """

  use HydepwnsLiveviewWeb, :live_view

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1]
  import HydepwnsLiveviewWeb.CoreComponents

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User

  @behaviour Phoenix.LiveView

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
    |> assign(:changeset, Accounts.change_user(%User{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
    |> assign(:changeset, Accounts.change_user(Accounts.get_user!(id)))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.live_action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_redirect(to: ~p"/users")}

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
         |> push_redirect(to: ~p"/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6"><%= @page_title %></h1>

      <.form
        :let={f}
        for={@changeset}
        id="user-form"
        phx-change="validate"
        phx-submit="save"
      >
        <div class="bg-white shadow rounded-lg p-6">
          <div class="space-y-6">
            <div>
              <.label for={f[:email].id}>Email</.label>
              <.input field={f[:email]} type="email" />
              <.error :for={msg <- Keyword.get_values(f[:email].errors, :email)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:name].id}>Name</.label>
              <.input field={f[:name]} type="text" />
              <.error :for={msg <- Keyword.get_values(f[:name].errors, :name)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:password].id}>Password</.label>
              <.input field={f[:password]} type="password" />
              <.error :for={msg <- Keyword.get_values(f[:password].errors, :password)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:password_confirmation].id}>Confirm Password</.label>
              <.input field={f[:password_confirmation]} type="password" />
              <.error :for={msg <- Keyword.get_values(f[:password_confirmation].errors, :password_confirmation)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:role].id}>Role</.label>
              <.input field={f[:role]} type="select" options={[User: "user", Admin: "admin"]} />
              <.error :for={msg <- Keyword.get_values(f[:role].errors, :role)}>
                <%= msg %>
              </.error>
            </div>

            <div class="flex justify-end">
              <.link navigate={~p"/users"} class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded mr-2">
                Cancel
              </.link>
              <.button type="submit" phx-disable-with="Saving...">
                Save User
              </.button>
            </div>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end 