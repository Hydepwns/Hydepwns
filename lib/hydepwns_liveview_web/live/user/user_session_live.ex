defmodule HydepwnsLiveviewWeb.UserSessionLive do
  @moduledoc """
  LiveView for user session management.
  """

  use HydepwnsLiveviewWeb, :live_view

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [input: 1, label_tag: 1, error: 1]

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Accounts.User
  alias HydepwnsLiveviewWeb.UserAuth

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, _params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Log in")
    |> assign(:user, %User{})
    |> assign(:changeset, Accounts.change_user_session(%User{}))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user_session(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params}, socket) do
    case UserAuth.log_in_user(socket, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Welcome back!")
         |> push_navigate(to: ~p"/users/#{user}")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid email or password")
         |> assign(:changeset, UserAuth.change_user_session(%{}))}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6">Log in</h1>

      <.form :let={f} for={@changeset} id="login-form" phx-change="validate" phx-submit="save">
        <div class="bg-white shadow rounded-lg p-6">
          <div class="space-y-6">
            <div>
              <.label_tag for={f[:email].id}>Email</.label_tag>
              <.input field={f[:email]} type="email" />
              <.error :for={msg <- Keyword.get_values(f[:email].errors, :email)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label_tag for={f[:password].id}>Password</.label_tag>
              <.input field={f[:password]} type="password" />
              <.error :for={msg <- Keyword.get_values(f[:password].errors, :password)}>
                <%= msg %>
              </.error>
            </div>

            <div class="flex justify-end">
              <.link navigate={~p"/users/register"} class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded mr-2">
                Register
              </.link>
              <.button type="submit" phx-disable-with="Signing in...">
                Log in
              </.button>
            </div>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
