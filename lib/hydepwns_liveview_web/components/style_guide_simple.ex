defmodule HydepwnsLiveviewWeb.Components.StyleGuideSimple do
  @moduledoc """
  Simplified style guide for testing.
  """
  use HydepwnsLiveviewWeb, :live_component

  @doc """
  Renders the style guide component.
  """
  def render(assigns) do
    ~H"""
    <div class="style-guide" id={@id}>
      <h1>Style Guide</h1>
      <p>This is a simplified style guide for testing.</p>
    </div>
    """
  end

  @doc """
  Mount function for the StyleGuide component.
  """
  def mount(socket) do
    {:ok, socket}
  end

  @doc """
  Update function for the StyleGuide component.
  """
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end 