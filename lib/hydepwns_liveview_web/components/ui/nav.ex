defmodule HydepwnsLiveviewWeb.Components.UI.Nav do
  @moduledoc """
  Navigation components for the application.

  Provides navigation elements like navbar, breadcrumbs, and navigation links
  with consistent styling and behavior.
  """
  use Phoenix.Component

  @doc """
  Renders a navigation link for the monospace theme.

  ## Examples

      <.nav_link navigate={~p"/"} active={@current_section == :home}>Home</.nav_link>
  """
  attr :navigate, :any, required: true
  attr :active, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "nav-link",
        @active && "active",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a horizontal navigation bar in the monospace style.

  ## Examples

      <.monospace_nav current_path={@current_path}>
        <:item path={~p"/"} label="Home" />
        <:item path={~p"/style-guide"} label="Style Guide" />
      </.monospace_nav>
  """
  attr :current_path, :string, required: true
  attr :class, :string, default: nil

  slot :item, required: true do
    attr :path, :string, required: true
    attr :label, :string, required: true
  end

  def monospace_nav(assigns) do
    ~H"""
    <nav class={["monospace-nav", @class]}>
      <ul class="monospace-nav-list">
        <%= for item <- @item do %>
          <li class="monospace-nav-item">
            <.nav_link
              navigate={item.path}
              active={@current_path == item.path}
              class="monospace-nav-link"
            >
              {item.label}
            </.nav_link>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders a table of contents (TOC) navigation in monospace style.

  ## Examples

      <.toc_nav>
        <:item id="introduction" label="Introduction" />
        <:item id="getting-started" label="Getting Started" />
      </.toc_nav>
  """
  attr :class, :string, default: nil

  slot :item, required: true do
    attr :id, :string, required: true
    attr :label, :string, required: true
  end

  def toc_nav(assigns) do
    ~H"""
    <nav id="TOC" role="doc-toc" class={@class}>
      <h2 id="toc-title">Contents</h2>
      <ul class="incremental">
        <%= for item <- @item do %>
          <li>
            <a href={"##{item.id}"} id={"toc-#{item.id}"}>
              {item.label}
            </a>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
