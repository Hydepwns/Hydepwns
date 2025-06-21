defmodule HydepwnsLiveviewWeb.Components.Common.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """

  use Phoenix.Component
  use Gettext, backend: HydepwnsLiveviewWeb.Gettext

  alias Phoenix.LiveView.JS
  import Phoenix.HTML

  # Common attributes for most components
  attr :id, :any, default: nil
  attr :name, :any, default: nil
  attr :label, :string, default: nil
  attr :value, :any, default: nil
  attr :error, :string, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  
  # Common slots
  slot :inner_block, required: false
  slot :subtitle
  slot :actions
  slot :actions_header

  # Modal component
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :title, :string, default: nil

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} phx-remove={hide_modal(@id)} data-cancel={JS.exec(@on_cancel, "phx-remove")} class="relative z-50 hidden">
      <div id={"#{@id}-bg"} class="bg-gray-500/75 transition-opacity fixed inset-0" aria-hidden="true" />
      <div class="fixed inset-0 overflow-y-auto" aria-labelledby={"#{@id}-title"} aria-describedby={"#{@id}-description"} role="dialog" aria-modal="true" tabindex="0">
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl overflow-hidden bg-white shadow-2xl sm:rounded-lg">
            <div class="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                  <h3 class="text-lg font-semibold leading-6 text-zinc-800" id={"#{@id}-title"}>
                    <%= @title %>
                  </h3>
                  <div class="mt-2" id={"#{@id}-description"}>
                    <%= render_slot(@inner_block) %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Label component
  attr :for, :any, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-medium text-gray-700">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  # Error component
  def error(assigns) do
    ~H"""
    <p class="mt-2 text-sm text-red-600">
      <.icon name="hero-exclamation-circle-mini" class="h-4 w-4" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  # Header component
  attr :title, :string, default: nil

  def header(assigns) do
    ~H"""
    <header class="flex items-center justify-between gap-6">
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= @title || render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div :if={@actions_header != []} class="flex-none">
        {render_slot(@actions_header)}
      </div>
    </header>
    """
  end

  # Icon component
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  # Harmonize slot keys to use :inner_block for consistency
  defp harmonize_slots(assigns) do
    # Debug: Log the original assigns
    IO.puts("DEBUG: Original assigns keys: #{inspect(Map.keys(assigns))}")
    
    harmonized = 
      assigns
      |> Map.keys()
      |> Enum.filter(&is_slot_key?/1)
      |> Enum.reduce(assigns, fn key, acc ->
        case key do
          :inner_block -> 
            IO.puts("DEBUG: Found :inner_block, keeping as is")
            acc
          :inner_block_button -> 
            IO.puts("DEBUG: Converting :inner_block_button to :inner_block")
            Map.put(acc, :inner_block, Map.get(acc, key))
          :inner_block_simple_form -> 
            IO.puts("DEBUG: Converting :inner_block_simple_form to :inner_block")
            Map.put(acc, :inner_block, Map.get(acc, key))
          key when is_atom(key) -> 
            key_str = Atom.to_string(key)
            if String.ends_with?(key_str, "_item") do
              IO.puts("DEBUG: Found multi-slot key: #{key}, keeping as is")
              acc
            else
              IO.puts("DEBUG: Converting slot key #{key} to :inner_block")
              Map.put(acc, :inner_block, Map.get(acc, key))
            end
          _ -> 
            IO.puts("DEBUG: Converting slot key #{key} to :inner_block")
            Map.put(acc, :inner_block, Map.get(acc, key))
        end
      end)
    
    # Debug: Log the harmonized assigns
    IO.puts("DEBUG: Harmonized assigns keys: #{inspect(Map.keys(harmonized))}")
    IO.puts("DEBUG: inner_block value: #{inspect(Map.get(harmonized, :inner_block))}")
    
    harmonized
  end

  # Check if a key is a slot key
  defp is_slot_key?(:inner_block), do: true
  defp is_slot_key?(:inner_block_button), do: true
  defp is_slot_key?(:inner_block_simple_form), do: true
  defp is_slot_key?(key) when is_atom(key) do
    key_str = Atom.to_string(key)
    String.ends_with?(key_str, "_item") or 
    String.starts_with?(key_str, "inner_block_")
  end
  defp is_slot_key?(_), do: false

  # Render slot content with debug output
  defp render_slot_content(slot_value, assigns \\ %{}, slot_key \\ :inner_block) do
    IO.puts("DEBUG: render_slot_content called with slot_value: #{inspect(slot_value)}, slot_key: #{inspect(slot_key)}")
    case slot_value do
      nil -> 
        IO.puts("DEBUG: Slot value is nil")
        ""
      slot_value when is_function(slot_value) ->
        arity = Function.info(slot_value, :arity)
        IO.puts("DEBUG: Slot value is function with arity: #{inspect(arity)}")
        try do
          case arity do
            {:arity, 2} -> 
              IO.puts("DEBUG: Calling function with assigns, nil")
              slot_value.(assigns, nil)
            {:arity, 1} -> 
              IO.puts("DEBUG: Calling function with assigns")
              slot_value.(assigns)
            {:arity, 0} -> 
              IO.puts("DEBUG: Calling function without args")
              slot_value.()
            arity -> 
              IO.puts("DEBUG: Unexpected function arity: #{inspect(arity)}")
              ""
          end
        rescue
          e -> 
            IO.puts("DEBUG: Error calling slot function: #{inspect(e)}")
            ""
        end
      slot_value when is_list(slot_value) ->
        IO.puts("DEBUG: Slot value is list with #{length(slot_value)} items, slot_key: #{inspect(slot_key)}")
        Enum.map_join(slot_value, "", fn item ->
          case item do
            %{^slot_key => block} when is_function(block) ->
              IO.puts("DEBUG: Rendering list item with function block for slot #{inspect(slot_key)}")
              arity = Function.info(block, :arity)
              case arity do
                {:arity, 2} -> block.(assigns, nil)
                {:arity, 1} -> block.(assigns)
                {:arity, 0} -> block.()
                _ -> ""
              end
            %{^slot_key => block} when is_binary(block) ->
              IO.puts("DEBUG: Rendering list item with string block: #{block}")
              block
            item when is_binary(item) ->
              IO.puts("DEBUG: Rendering list item as string: #{item}")
              item
            _ ->
              IO.puts("DEBUG: Rendering list item as inspect: #{inspect(item)}")
              inspect(item)
          end
        end)
      slot_value when is_binary(slot_value) ->
        IO.puts("DEBUG: Slot value is binary: #{slot_value}")
        slot_value
      _ ->
        IO.puts("DEBUG: Slot value is other type: #{inspect(slot_value)}")
        inspect(slot_value)
    end
  end

  def list(assigns) do
    IO.puts("DEBUG: list component called with assigns: #{inspect(Map.keys(assigns))}")
    assigns = harmonize_slots(assigns)
    # Add default class to prevent KeyError
    assigns = if Map.has_key?(assigns, :class), do: assigns, else: Map.put(assigns, :class, "")
    slot_content =
      case assigns[:_item] do
        nil -> render_slot_content(assigns[:inner_block], assigns, :inner_block)
        items when is_list(items) ->
          items
          |> Enum.map(fn item ->
            case item do
              %{inner_block: block, title: title} when is_function(block) ->
                content = render_slot_content(block, assigns)
                "#{title}: #{content}"
              %{inner_block: block} when is_function(block) ->
                render_slot_content(block, assigns)
              other -> inspect(other)
            end
          end)
          |> Enum.join("")
        val -> render_slot_content(val, assigns, :inner_block)
      end
    IO.puts("DEBUG: list slot content: #{inspect(slot_content)}")
    assigns = assign(assigns, :inner_block, slot_content)
    ~H"""
    <ul class={["list", @class]}>
      <%= @inner_block %>
    </ul>
    """
  end

  # Back component
  attr :href, :string, default: nil
  attr :patch, :string, default: nil
  attr :navigate, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block, required: false

  def back(assigns) do
    assigns = harmonize_slots(assigns)
    slot_content = render_slot_content(assigns[:inner_block], assigns)
    assigns = assign(assigns, :inner_block, slot_content)
    ~H"""
    <a href={@navigate} class={["back", @class]}>
      <%= @inner_block %>
    </a>
    """
  end

  # Icon component
  attr :name, :string, required: true
  attr :class, :string, default: nil
  slot :inner_block, required: false

  def icon_component(assigns) do
    assigns = harmonize_slots(assigns)
    ~H"""
    <span class={["icon", @class]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # Show div component
  attr :class, :string, default: nil
  slot :inner_block, required: false

  def show_div(assigns) do
    assigns = harmonize_slots(assigns)
    ~H"""
    <div class={["show", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # Hide div component
  attr :class, :string, default: nil
  slot :inner_block, required: false

  def hide_div(assigns) do
    assigns = harmonize_slots(assigns)
    ~H"""
    <div class={["hide", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def table(assigns) do
    IO.puts("DEBUG: table component called with assigns: #{inspect(Map.keys(assigns))}")
    assigns = harmonize_slots(assigns)
    assigns = if Map.has_key?(assigns, :class), do: assigns, else: Map.put(assigns, :class, "")
    slot_content =
      case {assigns[:row_item], assigns[:rows]} do
        {row_item_fn, rows} when is_function(row_item_fn) and is_list(rows) ->
          rows
          |> Enum.map(fn row ->
            arity = Function.info(row_item_fn, :arity)
            try do
              result = case arity do
                {:arity, 2} -> row_item_fn.(row, assigns)
                {:arity, 1} -> row_item_fn.(row)
                _ -> inspect(row)
              end
              cond do
                is_binary(result) -> result
                is_map(result) -> "<td>" <> inspect(result) <> "</td>"
                true -> to_string(result)
              end
            rescue
              _ -> inspect(row)
            end
          end)
          |> Enum.join("")
        {nil, _} -> render_slot_content(assigns[:inner_block], assigns, :inner_block)
        {val, _} -> 
          content = render_slot_content(val, assigns, :inner_block)
          if is_map(content) and not is_binary(content) do
            IO.puts("DEBUG: Table slot returned map, converting to string")
            inspect(content)
          else
            content
          end
      end
    IO.puts("DEBUG: table slot content: #{inspect(slot_content)}")
    assigns = assign(assigns, :inner_block, slot_content)
    ~H"""
    <div class="table-responsive">
      <table id={@id} class={["table", @class]}>
        <%= @inner_block %>
      </table>
    </div>
    """
  end

  # Link component
  attr :href, :string, default: nil
  attr :patch, :string, default: nil
  attr :navigate, :string, default: nil
  attr :phx_click, :any, default: nil
  attr :phx_value, :any, default: nil
  slot :inner_block, required: false

  def link_component(assigns) do
    assigns = harmonize_slots(assigns)
    ~H"""
    <.link class={["link", @class]} href={@href} patch={@patch} navigate={@navigate}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # Button component
  attr :type, :string, default: "button"
  attr :variant, :string, default: nil
  attr :size, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :phx_click, :string, default: nil
  attr :phx_submit, :string, default: nil
  attr :phx_value, :any, default: nil
  slot :inner_block, required: false

  def button(assigns) do
    IO.puts("DEBUG: button component called with assigns: #{inspect(Map.keys(assigns))}")
    
    assigns = harmonize_slots(assigns)
    
    # Handle both type and type_input attributes
    type = assigns[:type] || assigns[:type_input] || "button"
    
    # Get slot content
    slot_content = render_slot_content(assigns[:inner_block], assigns)
    IO.puts("DEBUG: button slot content: #{inspect(slot_content)}")
    
    assigns = assigns
    |> assign(:type, type)
    |> assign(:inner_block, slot_content)
    
    ~H"""
    <button type={@type} class={@class}>
      <%= @inner_block %>
    </button>
    """
  end

  # Flash component
  attr :flash, :map, default: %{}
  attr :kind, :atom, values: [:info, :error]
  attr :title, :string, default: nil
  attr :id_flash, :string, default: nil
  attr :on_cancel, JS, default: %JS{}

  def flash(assigns) do
    assigns = harmonize_slots(assigns)
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={@id_flash}
      phx-mounted={show("##{@id_flash}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id_flash}")}
      phx-hook="Flash"
      data-cancel={@on_cancel}
      role="alert"
      class={[
        "fixed top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
    >
      <p :if={@title} class="font-semibold leading-tight"><%= @title %></p>
      <p class="mt-2 leading-tight"><%= msg %></p>
      <button type="button" class="group absolute top-2 right-1 p-2" aria-label="close">
        <.icon_component name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  attr :flash_group_id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@flash_group_id}>
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash id="client-error" kind={:error} title="We can't find the internet" phx-disconnected={show(".phx-client-error #client-error")} phx-connected={hide("#client-error")} hidden>
        Attempting to reconnect <.icon_component name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash id="server-error" kind={:error} title="Something went wrong!" phx-disconnected={show(".phx-server-error #server-error")} phx-connected={hide("#server-error")} hidden>
        Hang in there while we get back on track. <.icon_component name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  # JS helper functions
  def show(js \\ %JS{}, selector) when is_binary(selector) do
    JS.show(js, to: selector)
  end

  def hide(js \\ %JS{}, selector) when is_binary(selector) do
    JS.hide(js, to: selector)
  end

  # Modal helper functions
  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  def nav(assigns) do
    IO.puts("DEBUG: nav component called with assigns: #{inspect(Map.keys(assigns))}")
    assigns = harmonize_slots(assigns)
    assigns = if Map.has_key?(assigns, :class), do: assigns, else: Map.put(assigns, :class, "")
    slot_content =
      cond do
        is_list(assigns[:_item]) -> 
          assigns[:_item]
          |> Enum.map(fn item ->
            case item do
              %{inner_block: block} when is_function(block) -> render_slot_content(block, assigns)
              other -> inspect(other)
            end
          end)
          |> Enum.join("")
        is_function(assigns[:_item]) -> render_slot_content(assigns[:_item], assigns, :inner_block)
        is_list(assigns[:inner_block]) ->
          assigns[:inner_block]
          |> Enum.map(fn item ->
            case item do
              %{inner_block: block} when is_function(block) -> render_slot_content(block, assigns)
              other -> inspect(other)
            end
          end)
          |> Enum.join("")
        is_function(assigns[:inner_block]) -> render_slot_content(assigns[:inner_block], assigns, :inner_block)
        true ->
          # Try to render @inner_block if present
          case assigns[:inner_block] do
            nil -> ""
            val when is_list(val) ->
              Enum.map(val, fn item ->
                case item do
                  %{inner_block: block} when is_function(block) -> render_slot_content(block, assigns)
                  other -> inspect(other)
                end
              end) |> Enum.join("")
            val when is_function(val) -> render_slot_content(val, assigns, :inner_block)
            _ -> ""
          end
      end
    IO.puts("DEBUG: nav slot content: #{inspect(slot_content)}")
    assigns = assign(assigns, :inner_block, slot_content)
    ~H"""
    <nav class={["nav", @class]}>
      <%= @inner_block %>
    </nav>
    """
  end

  def theme_toggle(assigns) do
    IO.puts("DEBUG: theme_toggle component called with assigns: #{inspect(Map.keys(assigns))}")
    assigns = harmonize_slots(assigns)
    assigns = if Map.has_key?(assigns, :class), do: assigns, else: Map.put(assigns, :class, "")
    slot_content = 
      cond do
        is_list(assigns[:inner_block]) ->
          assigns[:inner_block]
          |> Enum.map(fn item ->
            case item do
              %{inner_block: block} when is_function(block) -> render_slot_content(block, assigns)
              other -> inspect(other)
            end
          end)
          |> Enum.join("")
        is_function(assigns[:inner_block]) -> render_slot_content(assigns[:inner_block], assigns, :inner_block)
        true ->
          case assigns[:inner_block] do
            nil -> ""
            val when is_list(val) ->
              Enum.map(val, fn item ->
                case item do
                  %{inner_block: block} when is_function(block) -> render_slot_content(block, assigns)
                  other -> inspect(other)
                end
              end) |> Enum.join("")
            val when is_function(val) -> render_slot_content(val, assigns, :inner_block)
            _ -> ""
          end
      end
    IO.puts("DEBUG: theme_toggle slot content: #{inspect(slot_content)}")
    assigns = assign(assigns, :inner_block, slot_content)
    
    ~H"""
    <div class={["theme-toggle", @class]}>
      <button type="button" class="theme-toggle-btn">
        <span class="theme-toggle-icon">🌙</span>
      </button>
      <%= @inner_block %>
    </div>
    """
  end

  # Header table component
  attr :title, :string, required: true
  attr :version, :string, default: "1.0.0"
  attr :updated, :string, default: "Today"
  attr :author, :string, default: "Author"
  attr :license, :string, default: "MIT"
  attr :line_height, :string, default: "normal"

  def header_table(assigns) do
    ~H"""
    <header class="site-header">
      <h1><%= @title %></h1>
      <table class="metadata">
        <tr>
          <td>Version:</td>
          <td><%= @version %></td>
        </tr>
        <tr>
          <td>Updated:</td>
          <td><%= @updated %></td>
        </tr>
        <tr>
          <td>Author:</td>
          <td><%= @author %></td>
        </tr>
        <tr>
          <td>License:</td>
          <td><%= @license %></td>
        </tr>
        <tr>
          <td>Line height:</td>
          <td><%= @line_height %></td>
        </tr>
      </table>
    </header>
    """
  end

  def simple_form(assigns) do
    IO.puts("DEBUG: simple_form component called with assigns: #{inspect(Map.keys(assigns))}")
    assigns = harmonize_slots(assigns)
    # Add default for :rest to avoid KeyError
    assigns = if Map.has_key?(assigns, :rest), do: assigns, else: Map.put(assigns, :rest, [])
    # Add default class to prevent KeyError
    assigns = if Map.has_key?(assigns, :class), do: assigns, else: Map.put(assigns, :class, "")
    slot_content = render_slot_content(assigns[:inner_block], assigns)
    actions_content = render_slot_content(assigns[:actions], assigns)
    IO.puts("DEBUG: simple_form slot content: #{inspect(slot_content)}")
    IO.puts("DEBUG: simple_form actions content: #{inspect(actions_content)}")
    assigns = assign(assigns, :inner_block, slot_content)
    assigns = assign(assigns, :actions, actions_content)
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <%= @inner_block %>
      <div class="flex justify-end gap-3">
        <%= @actions %>
      </div>
    </.form>
    """
  end

  # Input component
  attr :type_input, :string, default: "text"
  attr :type, :string, default: nil
  attr :name, :string, required: true
  attr :id, :string, required: true
  attr :value, :any, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: []
  attr :options, :list, default: []
  attr :rest, :global

  def input(assigns) do
    # Harmonize input type for test compatibility
    input_type =
      cond do
        assigns[:type_input] && assigns[:type_input] != "text" -> assigns[:type_input]
        assigns[:type] in ["select", "textarea", "checkbox"] -> assigns[:type]
        true -> assigns[:type_input] || assigns[:type] || "text"
      end
    assigns = Map.put(assigns, :input_type, input_type)
    
    ~H"""
    <div class="form-group">
      <.label :if={@label} for={@id}><%= @label %></.label>
      <div class="mt-1">
        <%= case @input_type do %>
          <% "textarea" -> %>
            <textarea
              name={@name}
              id={@id}
              class={[
                "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm",
                @errors != [] && "border-red-300"
              ]}
              {@rest}
            ><%= @value %></textarea>
          <% "select" -> %>
            <select
              name={@name}
              id={@id}
              class={[
                "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm",
                @errors != [] && "border-red-300"
              ]}
              {@rest}
            >
              <%= for {value, label} <- @options do %>
                <option value={value} selected={@value == value}><%= label %></option>
              <% end %>
            </select>
          <% "checkbox" -> %>
            <input
              type="checkbox"
              name={@name}
              id={@id}
              value={@value}
              class={[
                "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm",
                @errors != [] && "border-red-300"
              ]}
              {@rest}
            />
          <% _ -> %>
            <input
              type={@input_type}
              name={@name}
              id={@id}
              value={@value}
              class={[
                "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm",
                @errors != [] && "border-red-300"
              ]}
              {@rest}
            />
        <% end %>
      </div>
      <.error :for={msg <- @errors}>
        <%= msg %>
      </.error>
    </div>
    """
  end
end 