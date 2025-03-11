defmodule HydepwnsLiveviewWeb.Components.Common.BaseComponents do
  @moduledoc """
  Base components and utilities shared between other component modules.

  This module breaks the circular dependency between CoreComponents
  and other UI component modules.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  # Common attribute definitions
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  # Common layout/structure patterns
  def container(assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # Common icon/button patterns
  def icon(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)

    ~H"""
    <span class={["icon", @class]} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  # Common modal-related helpers (extract from both existing components)
  def modal_container(assigns) do
    ~H"""
    <div id={@id} class={["modal-container", @class]} phx-remove={JS.transition("fade-out")} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # Common utility functions
  def hide_modal(id) when is_binary(id) do
    %JS{}
    |> JS.hide(to: "##{id}")
    |> JS.hide(to: "##{id}-bg", transition: "fade-out")
    |> JS.hide(to: "##{id}-container", transition: "fade-out-scale")
  end

  # Overload to support passing in an existing JS command
  def hide_modal(js, id) when is_binary(id) do
    js
    |> JS.hide(to: "##{id}")
    |> JS.hide(to: "##{id}-bg", transition: "fade-out")
    |> JS.hide(to: "##{id}-container", transition: "fade-out-scale")
  end

  # Move shared helper functions, attributes, and base components here
  # For example:

  # Shared utility functions
  def generate_id(prefix), do: "#{prefix}-#{Ecto.UUID.generate()}"

  # Add other shared component patterns here

  # -- COMMON FORM ELEMENTS --
  # Move basic form elements here from both core and form components
  def input_wrapper(assigns) do
    ~H"""
    <div class={["input-wrapper", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # Define a bare-bones version of commonly shared components here

  # -- COMMON UI UTILITIES --
  # Keep the JS-related functions

  # -- COMMON UTILITIES --
  # Add other general utility functions here
end
