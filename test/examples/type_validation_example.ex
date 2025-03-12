defmodule HydepwnsLiveviewWeb.Examples.TypeValidationExample do
  @moduledoc """
  Example LiveView demonstrating the type validation functionality.

  This module provides a practical example of using the type validation features
  introduced in Socket Validation Phase 5. It implements a simple form with
  type validation for various field types.

  To use in your application, add a route like:

  ```elixir
  # In your router.ex
  live "/examples/type-validation", HydepwnsLiveviewWeb.Examples.TypeValidationExample
  ```
  """
  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [:form, :validation_result, :page_title],
    type_specs: %{
      form: %{
        username: :string,
        age: :integer,
        subscribed: :boolean,
        preferences: %{
          theme: {:one_of, ["dark", "light", "dim", "synthwave"]},
          notifications: :boolean
        }
      },
      validation_result: %{
        valid: :boolean,
        errors: :list
      },
      page_title: :string
    }

  alias HydepwnsLiveview.Utils.SocketValidator

  @impl true
  def do_mount(_params, _session, socket) do
    # Initialize the form with default values
    form = %{
      username: "",
      age: 25,
      subscribed: false,
      preferences: %{
        theme: "dark",
        notifications: true
      }
    }

    # Initial validation result (empty since no validation has been performed yet)
    validation_result = %{
      valid: true,
      errors: []
    }

    socket
    |> assign(:form, form)
    |> assign(:validation_result, validation_result)
    |> assign(:page_title, "Type Validation Example")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">{@page_title}</h1>

      <div class="mb-8">
        <p class="mb-4">
          This example demonstrates LiveView socket type validation. Try changing values to see validation in action.
        </p>
      </div>

      <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg mb-8">
        <h2 class="text-2xl font-bold mb-4">Form with Type Validation</h2>

        <form phx-submit="validate_form" class="space-y-4">
          <div>
            <label class="block mb-2">Username (string)</label>
            <input type="text" name="username" value={@form.username} placeholder="Enter a username" class="w-full p-2 border rounded" phx-change="update_field" />
          </div>

          <div>
            <label class="block mb-2">Age (integer)</label>
            <input type="number" name="age" value={@form.age} class="w-full p-2 border rounded" phx-change="update_field" />
          </div>

          <div>
            <label class="flex items-center">
              <input type="checkbox" name="subscribed" checked={@form.subscribed} class="mr-2" phx-change="update_checkbox" />
              <span>Subscribed to newsletter (boolean)</span>
            </label>
          </div>

          <div>
            <label class="block mb-2">Theme (one_of)</label>
            <select name="theme" class="w-full p-2 border rounded" phx-change="update_field">
              <option value="dark" selected={@form.preferences.theme == "dark"}>Dark</option>
              <option value="light" selected={@form.preferences.theme == "light"}>Light</option>
              <option value="dim" selected={@form.preferences.theme == "dim"}>Dim</option>
              <option value="synthwave" selected={@form.preferences.theme == "synthwave"}>Synthwave</option>
              <option value="invalid_theme">Invalid Theme (for testing)</option>
            </select>
          </div>

          <div>
            <label class="flex items-center">
              <input type="checkbox" name="notifications" checked={@form.preferences.notifications} class="mr-2" phx-change="update_preferences_checkbox" />
              <span>Enable notifications (boolean in nested map)</span>
            </label>
          </div>

          <div class="mt-6">
            <button type="submit" class="bg-blue-500 text-white py-2 px-4 rounded">
              Validate Form
            </button>
          </div>
        </form>
      </div>

      <%= if length(@validation_result.errors) > 0 do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
          <h3 class="font-bold mb-2">Validation Errors</h3>
          <ul class="list-disc pl-5">
            <%= for error <- @validation_result.errors do %>
              <li>{error}</li>
            <% end %>
          </ul>
        </div>
      <% end %>

      <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg">
        <h2 class="text-2xl font-bold mb-4">Current Form State</h2>
        <pre class="bg-black text-green-400 p-4 rounded overflow-x-auto">
          <%= inspect(@form, pretty: true) %>
        </pre>

        <h3 class="text-xl font-bold mt-6 mb-2">Type Specifications</h3>
        <pre class="bg-black text-yellow-400 p-4 rounded overflow-x-auto">
          form: %{
            username: :string,
            age: :integer,
            subscribed: :boolean,
            preferences: %{
              theme: {:one_of, ["dark", "light", "dim", "synthwave"]},
              notifications: :boolean
            }
          }
        </pre>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event(
        "update_field",
        %{"_target" => [field], "username" => username, "age" => age, "theme" => theme},
        socket
      ) do
    # Convert age to integer, with fallback for invalid input
    {age, _} = Integer.parse(age)
  rescue
    {0, nil}

    # Update the form map with the new values
    form =
      update_in(socket.assigns.form, fn form ->
        form = %{form | username: username, age: age}

        # Update theme in preferences
        put_in(form, [:preferences, :theme], theme)
      end)

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event(
        "update_checkbox",
        %{"_target" => ["subscribed"], "subscribed" => subscribed},
        socket
      ) do
    form = put_in(socket.assigns.form.subscribed, subscribed == "on")
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event(
        "update_preferences_checkbox",
        %{"_target" => ["notifications"], "notifications" => notifications},
        socket
      ) do
    form = put_in(socket.assigns.form.preferences.notifications, notifications == "on")
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("validate_form", _params, socket) do
    # Get the current form from assigns
    form = socket.assigns.form

    # Define the type specs for validation
    form_spec = %{
      username: :string,
      age: :integer,
      subscribed: :boolean,
      preferences: %{
        theme: {:one_of, ["dark", "light", "dim", "synthwave"]},
        notifications: :boolean
      }
    }

    # Create a socket with the form as a direct assign for validation
    validation_socket =
      Phoenix.Component.assign(%Phoenix.LiveView.Socket{}, :validation_target, form)

    # Validate against the type spec
    case SocketValidator.type_validation(validation_socket, :validation_target, form_spec) do
      {:ok, _} ->
        validation_result = %{
          valid: true,
          errors: []
        }

        {:noreply, assign(socket, :validation_result, validation_result)}

      {:error, message, _} ->
        # Extract specific errors from the message
        errors = extract_validation_errors(message)

        validation_result = %{
          valid: false,
          errors: errors
        }

        {:noreply, assign(socket, :validation_result, validation_result)}
    end
  end

  # Helper to extract specific errors from the validation message
  defp extract_validation_errors(message) do
    # For a message like: "Invalid type for validation_target: schema validation failed: age: expected integer, preferences.theme: expected one of ["dark", "light", "dim", "synthwave"]"
    # Extract each individual error

    if String.contains?(message, "schema validation failed:") do
      # Split the message to get the part after "schema validation failed:"
      [_, errors_part] = String.split(message, "schema validation failed:", parts: 2)

      # Split the errors by comma and trim whitespace
      String.split(errors_part, ",")
      |> Enum.map(&String.trim/1)
    else
      # For non-schema errors, just return the whole message
      [message]
    end
  end
end
