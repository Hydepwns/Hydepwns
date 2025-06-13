defmodule HydepwnsLiveviewWeb.Components.Common.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """

  use Phoenix.Component
  use Gettext, backend: HydepwnsLiveviewWeb.Gettext

  alias Phoenix.LiveView.JS

  # Common attributes for most components
  attr :id, :any, default: nil
  attr :name, :any, default: nil
  attr :label, :string, default: nil
  attr :value, :any, default: nil
  attr :error, :string, default: nil
  attr :required, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  slot :inner_block, required: false

  def list(assigns) do
    ~H"""
    <ul class={["list", @class]}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  def back(assigns) do
    ~H"""
    <.link_component
      class={[
        "back-link",
        @class
      ]}
      href={@href}
      patch={@patch}
      navigate={@navigate}
    >
      <%= render_slot(@inner_block) %>
    </.link_component>
    """
  end

  def icon_component(assigns) do
    ~H"""
    <span class={["icon", @class]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  def show(assigns) do
    ~H"""
    <div class={["show", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def hide(assigns) do
    ~H"""
    <div class={["hide", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :type, :string, default: nil
  attr :rest, :global
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :id_flash, :string, doc: "the optional id of flash container"
  attr :flash_group_id, :string, default: "flash-group", doc: "the optional id of flash container"

  # Table component
  attr :class, :string, default: nil
  slot :inner_block, required: false
  def table(assigns) do
    ~H"""
    <div class="table-responsive">
      <table class={["table", @class]}>
        <%= render_slot(@inner_block) %>
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
  attr :class, :string, default: nil
  slot :inner_block, required: false
  def link_component(assigns) do
    ~H"""
    <.link
      class={["link", @class]}
      href={@href}
      patch={@patch}
      navigate={@navigate}
      phx_click={@phx_click}
      phx_value={@phx_value}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn",
        @variant && "btn-#{@variant}",
        @size && "btn-#{@size}",
        @class
      ]}
      disabled={@disabled}
      phx-click={@phx_click}
      phx-submit={@phx_submit}
      phx-value={@phx_value}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={@id_flash}
      phx-mounted={show("#{@id_flash}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("#{@id_flash}")}
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
      <button
        type="button"
        class="group absolute top-2 right-1 p-2"
        aria-label="close"
      >
        <.icon_component name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  def flash_group(assigns) do
    ~H"""
    <div id={@flash_group_id}>
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        Attempting to reconnect <.icon_component name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        Hang in there while we get back on track.
        <.icon_component name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  def show(js \\ %JS{}, selector) when is_binary(selector) do
    JS.show(js, to: selector)
  end

  def hide(js \\ %JS{}, selector) when is_binary(selector) do
    JS.hide(js, to: selector)
  end
end
