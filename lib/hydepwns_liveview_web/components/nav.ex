defmodule HydepwnsLiveviewWeb.Components.Nav do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :link, :string, required: true
    attr :active, :boolean, default: false
  end

  def nav(assigns) do
    ~H"""
    <nav class={["flex space-x-4", @class]} {@rest}>
      <%= for item <- @item do %>
        <.link
          navigate={item.link}
          class={[
            "px-3 py-2 rounded-md text-sm font-medium",
            if item[:active],
              do: "bg-blue-600 text-white dark:bg-blue-700",
              else: "text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-800"
          ]}
        >
          <%= render_slot(item) %>
        </.link>
      <% end %>
    </nav>
    """
  end
end
