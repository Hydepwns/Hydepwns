defmodule HydepwnsLiveviewWeb.Components.UI.LayoutComponents do
  @moduledoc """
  Provides layout UI components.
  """
  use Phoenix.Component
  use Gettext, backend: HydepwnsLiveviewWeb.Gettext

  # Import base components
  import HydepwnsLiveviewWeb.Components.BaseComponents

  # Remove import of CoreComponents (if present)
  # import HydepwnsLiveviewWeb.CoreComponents

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@class]}>
      <div class="flex items-center justify-between gap-6">
        <div>
          <h1 class="text-lg font-semibold leading-8 text-zinc-800">
            <%= render_slot(@inner_block) %>
          </h1>
          <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
            <%= render_slot(@subtitle) %>
          </p>
        </div>
        <div class="flex-none"><%= render_slot(@actions) %></div>
      </div>
    </header>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a header with a table layout.
  """
  attr :class, :string, default: nil
  slot :left, required: true
  slot :right

  def header_table(assigns) do
    ~H"""
    <header class={["site-header", @class]}>
      <div class="header-grid">
        <div class="header-left">
          <%= render_slot(@left) %>
        </div>
        <div class="header-right">
          <%= render_slot(@right) %>
        </div>
      </div>
    </header>
    """
  end
  
  @doc """
  Renders a navigation component.
  """
  attr :class, :string, default: nil
  slot :inner_block
  slot :item, required: false do
    attr :link, :any
    attr :active, :boolean
  end

  def nav(assigns) do
    ~H"""
    <nav class={["site-nav", @class]}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= for item <- @item do %>
          <a href={item.link} class={if Map.get(item, :active, false), do: "active"}>
            <%= render_slot(item) %>
          </a>
        <% end %>
      <% end %>
    </nav>
    """
  end
end 