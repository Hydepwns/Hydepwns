defmodule HydepwnsLiveviewWeb.Components.UI.MonoTabs do
  @moduledoc """
  Monospace tabbed interface component that maintains grid alignment.
  
  This component provides a tabbed interface with consistent monospace styling,
  ensuring tabs and content maintain proper grid alignment. Tabs can be rendered
  in different styles (bordered, underlined, or boxed) while preserving the
  monospace aesthetic.
  """
  use Phoenix.Component
  import HydepwnsLiveviewWeb.Components.MonoGrid
  alias Phoenix.LiveView.JS
  
  @doc """
  Renders a monospace tabbed interface.
  
  ## Examples
  
      <.mono_tabs id="demo-tabs">
        <:tab id="tab1" title="First Tab">
          Content for first tab goes here
        </:tab>
        <:tab id="tab2" title="Second Tab">
          Content for second tab goes here
        </:tab>
      </.mono_tabs>
  
  ## Attributes
  
  * `id` - Required unique identifier for the tabs component
  * `class` - Additional CSS classes to add to the tabs container
  * `style` - Tab styling variant: :bordered, :underlined, :boxed (default: :bordered)
  * `active_tab` - ID of the initially active tab (defaults to first tab)
  * `vertical` - Whether tabs should be arranged vertically (default: false)
  """
  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :style, :atom, default: :bordered, values: [:bordered, :underlined, :boxed]
  attr :active_tab, :string, default: nil
  attr :vertical, :boolean, default: false
  attr :rest, :global
  
  slot :tab, required: true do
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :icon, :string
  end
  
  def mono_tabs(assigns) do
    # Determine the active tab (use active_tab if provided, otherwise use the first tab)
    active_tab = 
      if assigns.active_tab, 
        do: assigns.active_tab, 
        else: get_first_tab_id(assigns.tab)
    
    assigns = assign(assigns, :active_tab, active_tab)
    
    ~H"""
    <div 
      id={@id} 
      class={["mono-tabs", "mono-tabs--#{@style}", @vertical && "mono-tabs--vertical", @class]} 
      {@rest}
      phx-hook="MonoTabs"
      data-tabs-id={@id}
    >
      <div class="mono-tabs__nav" role="tablist">
        <%= for tab <- @tab do %>
          <button 
            type="button"
            id={"#{@id}-tab-#{tab.id}"} 
            class={["mono-tabs__tab", @active_tab == tab.id && "mono-tabs__tab--active"]} 
            role="tab"
            aria-selected={@active_tab == tab.id}
            aria-controls={"#{@id}-panel-#{tab.id}"}
            phx-click={show_tab(@id, tab.id)}
          >
            <%= if Map.get(tab, :icon) do %>
              <span class="mono-tabs__icon"><%= tab.icon %></span>
            <% end %>
            <span class="mono-tabs__title"><%= tab.title %></span>
          </button>
        <% end %>
      </div>
      
      <div class="mono-tabs__content">
        <%= for tab <- @tab do %>
          <div 
            id={"#{@id}-panel-#{tab.id}"} 
            class={["mono-tabs__panel", @active_tab == tab.id && "mono-tabs__panel--active"]} 
            role="tabpanel"
            aria-labelledby={"#{@id}-tab-#{tab.id}"}
            hidden={@active_tab != tab.id}
          >
            <.mono_grid cols={78}>
              <.mono_grid_row>
                <.mono_grid_cell cols={78}>
                  <%= render_slot(tab) %>
                </.mono_grid_cell>
              </.mono_grid_row>
            </.mono_grid>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  # Helper function to show a specific tab
  defp show_tab(tabs_id, tab_id) do
    JS.remove_class("mono-tabs__tab--active", to: "##{tabs_id} .mono-tabs__tab")
    |> JS.add_class("mono-tabs__tab--active", to: "##{tabs_id}-tab-#{tab_id}")
    |> JS.set_attribute({"aria-selected", "true"}, to: "##{tabs_id}-tab-#{tab_id}")
    |> JS.set_attribute({"aria-selected", "false"}, to: "##{tabs_id} .mono-tabs__tab:not(##{tabs_id}-tab-#{tab_id})")
    |> JS.remove_class("mono-tabs__panel--active", to: "##{tabs_id} .mono-tabs__panel")
    |> JS.add_class("mono-tabs__panel--active", to: "##{tabs_id}-panel-#{tab_id}")
    |> JS.remove_attribute("hidden", to: "##{tabs_id}-panel-#{tab_id}")
    |> JS.set_attribute({"hidden", "true"}, to: "##{tabs_id} .mono-tabs__panel:not(##{tabs_id}-panel-#{tab_id})")
  end
  
  # Helper function to get the ID of the first tab
  defp get_first_tab_id([]), do: nil
  defp get_first_tab_id([first_tab | _]), do: first_tab.id
end 