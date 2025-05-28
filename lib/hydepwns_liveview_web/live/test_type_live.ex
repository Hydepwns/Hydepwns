defmodule HydepwnsLiveview.TypeValidationTest.TestTypeLive do
  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [:string_value, :integer_value, :theme],
    type_specs: %{
      string_value: :string,
      integer_value: :integer,
      optional_list: :list,
      theme: {:one_of, ["dark", "light", "dim"]},
      user: %{
        name: :string,
        admin: :boolean
      },
      tags: {:list, :string},
      id_or_name: {:union, [:integer, :string]}
    }

  def mount(_params, session, socket) do
    socket =
      socket
      |> Phoenix.Component.assign(:string_value, Map.get(session, "string_value", "default"))
      |> Phoenix.Component.assign(:integer_value, Map.get(session, "integer_value", 42))
      |> Phoenix.Component.assign(:theme, Map.get(session, "theme", "dark"))
      |> assign_optional_values(session)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p>String value: {@string_value}</p>
      <p>Integer value: {@integer_value}</p>
      <p>Theme: {@theme}</p>
      <%= if Map.has_key?(assigns, :optional_list) do %>
        <p>Optional list: {inspect(@optional_list)}</p>
      <% end %>
      <%= if Map.has_key?(assigns, :user) do %>
        <p>User: {@user.name} (Admin: {@user.admin})</p>
      <% end %>
      <%= if Map.has_key?(assigns, :tags) do %>
        <p>Tags: {inspect(@tags)}</p>
      <% end %>
      <%= if Map.has_key?(assigns, :id_or_name) do %>
        <p>ID or Name: {inspect(@id_or_name)}</p>
      <% end %>
    </div>
    """
  end

  defp assign_optional_values(socket, session) do
    socket
    |> maybe_assign(:optional_list, Map.get(session, "optional_list"))
    |> maybe_assign(:user, Map.get(session, "user"))
    |> maybe_assign(:tags, Map.get(session, "tags"))
    |> maybe_assign(:id_or_name, Map.get(session, "id_or_name"))
  end

  defp maybe_assign(socket, _key, nil), do: socket
  defp maybe_assign(socket, key, value), do: Phoenix.Component.assign(socket, key, value)
end 