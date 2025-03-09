defmodule HydepwnsLiveviewWeb.Components.UI.DebugGrid do
  use Phoenix.Component
  
  # Add the alias for Phoenix.LiveView.JS
  alias Phoenix.LiveView.JS

  @moduledoc """
  Debug grid component for visualizing layout alignment.
  
  Provides a visual grid overlay that can be toggled on/off to help with
  debugging and aligning UI elements during development.
  """

  @doc """
  Renders a debug grid toggle for visualizing the monospace grid alignment.
  
  ## Example
  
      <.debug_grid />
  """
  attr :class, :string, default: nil
  attr :rest, :global

  def debug_grid(assigns) do
    ~H"""
    <div id="debug-grid" class="debug-grid" phx-update="ignore" style="display: none;">
      <!-- grid content -->
    </div>

    <button phx-click={JS.toggle(to: "#debug-grid")}>
      Toggle Debug Grid
    </button>
    """
  end
end 