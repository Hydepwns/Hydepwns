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
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
