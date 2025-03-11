defmodule HydepwnsLiveviewWeb.Components.UI.MonoForm do
  @moduledoc """
  Monospace form components that maintain the grid alignment.
  
  This module provides form elements styled in a monospace aesthetic,
  carefully aligned using character units (ch) to maintain the grid system
  across all form controls. This ensures consistent spacing and alignment
  with the rest of the monospace styled application.
  """
  use Phoenix.Component
  import Phoenix.HTML.Form
  
  @doc """
  Renders a monospace form.
  
  ## Examples
  
      <.mono_form for={@form} phx-submit="save">
        <.mono_input field={@form[:name]} label="Name" />
        <.mono_input field={@form[:email]} type="email" label="Email" />
        <.mono_submit>Save</.mono_submit>
      </.mono_form>
  
  ## Attributes
  
  * `for` - The form struct from `Phoenix.HTML.Form`
  * `as` - The name to use for the form
  * `rest` - Additional attributes to add to the form element
  """
  attr :for, :any, required: true
  attr :as, :any, default: nil
  attr :rest, :global, include: ~w(autocomplete name method action enctype)
  
  slot :inner_block, required: true
  
  def mono_form(assigns) do
    ~H"""
    <.form for={@for} as={@as} {@rest} class="mono-form">
      <%= render_slot(@inner_block) %>
    </.form>
    """
  end
  
  @doc """
  Renders a monospace form input.
  
  ## Examples
  
      <.mono_input field={@form[:name]} label="Name" />
      <.mono_input field={@form[:email]} type="email" label="Email" />
      <.mono_input field={@form[:password]} type="password" label="Password" />
      <.mono_input field={@form[:bio]} type="textarea" label="Bio" />
  
  ## Attributes
  
  * `field` - The form field struct from the form
  * `label` - The label text for the input
  * `type` - The type of input (default: "text")
  * `required` - Whether the input is required (default: false)
  * `autocomplete` - Autocomplete attribute value
  * `placeholder` - Placeholder text
  * `min_length` - Minimum length for text inputs
  * `max_length` - Maximum length for text inputs
  * `min` - Minimum value for number inputs
  * `max` - Maximum value for number inputs
  * `step` - Step value for number inputs
  * `helper_text` - Optional text to display below the input
  * `error_class` - Additional CSS class for error state
  * `class` - Additional CSS classes
  * `rest` - Additional attributes
  """
  attr :id, :any, default: nil
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"
  attr :label, :string, default: nil
  attr :type, :string, default: "text", 
    values: ~w(checkbox color date datetime-local email file hidden month number
               password range radio search select tel text textarea time url week)
  attr :required, :boolean, default: false
  attr :pattern, :string, default: nil
  attr :autocomplete, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :min_length, :integer, default: nil
  attr :max_length, :integer, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :step, :any, default: nil
  attr :rows, :integer, default: 5
  attr :cols, :integer, default: 40
  attr :options, :list, default: []
  attr :helper_text, :string, default: nil
  attr :error_class, :string, default: "mono-input--error"
  attr :class, :string, default: nil
  attr :rest, :global
  
  def mono_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    # If the field was previously submitted and there are errors, mark it as error
    assigns = assign_new(assigns, :errors, fn -> field.errors end)
    has_error = length(assigns.errors) > 0
    
    # Generate input id if not provided
    assigns =
      if is_nil(assigns.id) do
        assign(assigns, :id, field.id)
      else
        assigns
      end
    
    # Add error class if there are errors
    input_class = if has_error, do: assigns.error_class, else: ""
    assigns = assign(assigns, :input_class, input_class)
    
    ~H"""
    <div class={["mono-input-container", @class]}>
      <%= if @label do %>
        <div class="mono-label-container">
          <label for={@id} class="mono-label">
            <%= @label %><%= if @required do %> <span class="mono-required">*</span><% end %>
          </label>
        </div>
      <% end %>
      <div class="mono-field-container">
        <%= render_input(assigns) %>
      </div>
      <%= if @helper_text do %>
        <div class="mono-helper-text">
          <%= @helper_text %>
        </div>
      <% end %>
      <%= for error <- @errors do %>
        <div class="mono-error-text">
          <%= humanize(error) %>
        </div>
      <% end %>
    </div>
    """
  end
  
  # Helper function to render a text input
  defp render_input(%{type: "textarea"} = assigns) do
    ~H"""
    <textarea
      id={@id}
      name={@field.name}
      class={["mono-textarea", @input_class]}
      placeholder={@placeholder}
      autocomplete={@autocomplete}
      rows={@rows}
      cols={@cols}
      required={@required}
      aria-invalid={@errors != [] && "true"}
      aria-describedby={@errors != [] && "#{@id}_feedback"}
      {@rest}
    ><%= Phoenix.HTML.Form.normalize_value("textarea", @field.value) %></textarea>
    """
  end
  
  defp render_input(%{type: "select"} = assigns) do
    ~H"""
    <select
      id={@id}
      name={@field.name}
      class={["mono-select", @input_class]}
      required={@required}
      aria-invalid={@errors != [] && "true"}
      aria-describedby={@errors != [] && "#{@id}_feedback"}
      {@rest}
    >
      <%= for {option_key, option_value} <- @options do %>
        <option value={option_key} selected={@field.value == option_key}><%= option_value %></option>
      <% end %>
    </select>
    """
  end
  
  defp render_input(%{type: "checkbox"} = assigns) do
    ~H"""
    <label class="mono-checkbox-container">
      <input
        type="checkbox"
        id={@id}
        name={@field.name}
        class={["mono-checkbox", @input_class]}
        checked={Phoenix.HTML.Form.normalize_value("checkbox", @field.value)}
        required={@required}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={@errors != [] && "#{@id}_feedback"}
        {@rest}
      />
      <span class="mono-checkbox-mark"></span>
    </label>
    """
  end
  
  defp render_input(%{type: "radio"} = assigns) do
    ~H"""
    <label class="mono-radio-container">
      <input
        type="radio"
        id={@id}
        name={@field.name}
        class={["mono-radio", @input_class]}
        checked={Phoenix.HTML.Form.normalize_value("radio", @field.value)}
        required={@required}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={@errors != [] && "#{@id}_feedback"}
        {@rest}
      />
      <span class="mono-radio-mark"></span>
    </label>
    """
  end
  
  defp render_input(assigns) do
    ~H"""
    <input
      type={@type}
      id={@id}
      name={@field.name}
      value={Phoenix.HTML.Form.normalize_value(@type, @field.value)}
      class={["mono-input", @input_class]}
      placeholder={@placeholder}
      autocomplete={@autocomplete}
      required={@required}
      pattern={@pattern}
      min={@min}
      max={@max}
      step={@step}
      minlength={@min_length}
      maxlength={@max_length}
      aria-invalid={@errors != [] && "true"}
      aria-describedby={@errors != [] && "#{@id}_feedback"}
      {@rest}
    />
    """
  end
  
  @doc """
  Renders a submit button for a monospace form.
  
  ## Examples
  
      <.mono_submit>Submit</.mono_submit>
      <.mono_submit disabled={@submitting}>
        <%= if @submitting, do: "Submitting...", else: "Submit" %>
      </.mono_submit>
  
  ## Attributes
  
  * `class` - Additional CSS classes
  * `disabled` - Whether the button is disabled
  * `rest` - Additional attributes
  """
  attr :class, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :type, :string, default: "submit"
  attr :rest, :global
  
  slot :inner_block, required: true
  
  def mono_submit(assigns) do
    ~H"""
    <div class="mono-submit-container">
      <button
        type={@type}
        class={["mono-submit", @class]}
        disabled={@disabled}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </button>
    </div>
    """
  end
  
  @doc """
  Renders a button for a monospace form.
  
  ## Examples
  
      <.mono_button>Click Me</.mono_button>
      <.mono_button phx-click="perform_action" disabled={@loading}>
        <%= if @loading, do: "Processing...", else: "Perform Action" %>
      </.mono_button>
  
  ## Attributes
  
  * `class` - Additional CSS classes
  * `disabled` - Whether the button is disabled
  * `type` - Button type, defaults to "button"
  * `rest` - Additional attributes
  """
  attr :class, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :type, :string, default: "button"
  attr :rest, :global
  
  slot :inner_block, required: true
  
  def mono_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={["mono-button", @class]}
      disabled={@disabled}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
  
  @doc """
  Utility function to humanize an error message or atom.
  """
  def humanize(value) when is_atom(value), do: Phoenix.Naming.humanize(value)
  def humanize(value) when is_binary(value), do: value
end 