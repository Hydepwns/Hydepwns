defmodule HydepwnsLiveviewWeb.Components.Button do
  use Phoenix.Component

  attr :type, :string, default: "button"
  attr :class, :string, default: nil
  attr :variant, :string, default: "default"
  attr :size, :string, default: "md"
  attr :disabled, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: true

  def button(assigns) do
    base_classes = "inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none"
    
    variant_classes = case assigns.variant do
      "default" -> "bg-blue-600 text-white hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-800"
      "outline" -> "border border-gray-300 dark:border-gray-600 bg-transparent hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-900 dark:text-gray-100"
      "ghost" -> "bg-transparent hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-900 dark:text-gray-100"
      _ -> "bg-blue-600 text-white hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-800"
    end
    
    size_classes = case assigns.size do
      "sm" -> "h-8 px-3 text-sm"
      "md" -> "h-10 px-4 py-2"
      "lg" -> "h-12 px-6 py-3 text-lg"
      _ -> "h-10 px-4 py-2"
    end
    
    classes = [base_classes, variant_classes, size_classes, assigns.class]

    assigns = assign(assigns, :classes, Enum.join(classes, " "))

    ~H"""
    <button type={@type} class={@classes} disabled={@disabled} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
