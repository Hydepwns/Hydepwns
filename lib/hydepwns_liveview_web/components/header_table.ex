defmodule HydepwnsLiveviewWeb.Components.HeaderTable do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global

  slot :header, required: true
  slot :row, required: true

  def header_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class={["min-w-full divide-y divide-gray-200 dark:divide-gray-700", @class]} {@rest}>
        <thead class="bg-gray-50 dark:bg-gray-700">
          <tr>
            <%= for header <- @header do %>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                <%= render_slot(header) %>
              </th>
            <% end %>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <%= for row <- @row do %>
            <tr class="hover:bg-gray-50 dark:hover:bg-gray-700">
              <%= render_slot(row) %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
