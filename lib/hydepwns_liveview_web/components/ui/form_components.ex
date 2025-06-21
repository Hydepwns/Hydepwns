defmodule HydepwnsLiveviewWeb.Components.UI.FormComponents do
  @moduledoc """
  Form-related components and utilities.
  """
  use Phoenix.Component
  use Gettext, backend: HydepwnsLiveviewWeb.Gettext
  import Phoenix.HTML.Form

  alias Phoenix.LiveView.JS

  # Common attributes
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  # Flash-related attributes
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :id_flash, :string, doc: "the optional id of flash container"
  attr :flash_group_id, :string, default: "flash-group", doc: "the optional id of flash container"

  # Form-related attributes
  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type_input, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  # Slots
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} id={@id} class={@class}>
      <%= render_slot(@inner_block, f) %>
    </.form>
    """
  end

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if input_value(assigns[:form], field.name), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns[:id] || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns[:multiple], do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> assign_new(:type_input, fn -> assigns[:type] || "text" end)
    |> assign_new(:rest, fn -> %{} end)
    |> assign_new(:label, fn -> nil end)
    |> assign_new(:multiple, fn -> assigns[:multiple] || false end)
    |> assign_new(:prompt, fn -> assigns[:prompt] end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        input_value(assigns[:form], assigns[:name])
      end)

    ~H"""
    <div>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input type="checkbox" id={@id} name={@name} value="true" checked={@checked} class="rounded border-zinc-300 text-zinc-900 focus:ring-0" {@rest} /> {@label}
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    assigns =
      assigns
      |> assign_new(:multiple, fn -> assigns[:multiple] || false end)
      |> assign_new(:prompt, fn -> assigns[:prompt] end)

    ~H"""
    <div data-test-id={"#{@id}-container"}>
      <.label_tag for={@id}>{@label}</.label_tag>
      <select id={@id} name={@name} class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm" multiple={@multiple} data-test-id={@id} {@rest}>
        <option :if={@prompt} value=""><%= @prompt %></option>
        {options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors} data-test-id={"#{@id}-error"}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div data-test-id={"#{@id}-container"}>
      <.label_tag for={@id}>{@label}</.label_tag>
      <textarea
        id={@id}
        name={@name}
        data-test-id={@id}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem]",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      >{input_value(@form, @name)}</textarea>
      <.error :for={msg <- @errors} data-test-id={"#{@id}-error"}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class="form-group">
      <.label_tag for={@id}>{@label}</.label_tag>
      <input 
        type={@type_input}
        id={@id} 
        name={@name} 
        value={@value} 
        class={["form-control", @errors != [] && "is-invalid"]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  defp error_tag(form, field) do
    errors = if input_value(form, field), do: form.errors[field], else: []
    Enum.map(errors, fn error ->
      Phoenix.HTML.Tag.content_tag(:span, translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  def label_tag(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id={"#{@for}-label"}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  def label(assigns) do
    ~H"""
    <label><%= assigns[:for] || "Label" %></label>
    """
  end

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600" data-test-id={@rest[:data_test_id]}>
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" /> {render_slot(@inner_block)}
    </p>
    """
  end

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  def icon(assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  # Button-specific attributes
  attr :type, :string, default: "button"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Translates a single error tuple using Gettext.
  """
  @spec translate_error({String.t(), keyword()}) :: String.t()
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(HydepwnsLiveviewWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(HydepwnsLiveviewWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates all errors for a given field from a list of error tuples.
  """
  @spec translate_errors(list(), atom()) :: list(String.t())
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
