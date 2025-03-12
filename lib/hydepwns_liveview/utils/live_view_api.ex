defmodule HydepwnsLiveview.Utils.LiveViewAPI do
  @moduledoc """
  Provides an API-style interface for LiveView socket assigns.

  This module implements standardized API methods for accessing and manipulating
  LiveView socket assigns in a consistent way, inspired by Ash Framework's API patterns.

  ## Features

  - Standardized methods for reading, updating, and managing socket assigns
  - Consistent error handling and validation
  - Domain-oriented organization of LiveView functionality
  - Support for resource-oriented socket assigns

  ## Usage

  ```elixir
  # In a LiveView module
  alias HydepwnsLiveview.Utils.LiveViewAPI

  def handle_event("update_user", %{"user" => user_params}, socket) do
    case LiveViewAPI.update(socket, :user, user_params) do
      {:ok, updated_socket} ->
        {:noreply, updated_socket}
      
      {:error, message, socket} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("get_user_role", _, socket) do
    role = LiveViewAPI.get(socket, :user, :role)
    
    # Do something with the role...
    
    {:noreply, socket}
  end
  """

  alias Phoenix.LiveView.Socket
  alias HydepwnsLiveview.Utils.SocketValidator
  alias HydepwnsLiveview.Utils.LiveViewResource

  @doc """
  Gets a value from a resource-oriented socket assign.

  ## Parameters

  - `socket` - The LiveView socket.
  - `resource` - The resource key in the socket assigns.
  - `field` - The field within the resource to get.
  - `default` - Optional default value to return if the field doesn't exist.

  ## Returns

  The value of the specified field, or the default value if it doesn't exist.

  ## Examples

  ```elixir
  # Get the user's role
  role = LiveViewAPI.get(socket, :user, :role)

  # Get the user's theme with a default
  theme = LiveViewAPI.get(socket, :user, :theme, "light")
  ```
  """
  def get(%Socket{} = socket, resource, field, default \\ nil)
      when is_atom(resource) and is_atom(field) do
    socket.assigns
    |> Map.get(resource, %{})
    |> Map.get(field, default)
  end

  @doc """
  Gets a value directly from socket assigns.

  ## Parameters

  - `socket` - The LiveView socket.
  - `field` - The field to get from the assigns.
  - `default` - Optional default value to return if the field doesn't exist.

  ## Returns

  The value of the specified field, or the default value if it doesn't exist.

  ## Examples

  ```elixir
  # Get the current theme
  theme = LiveViewAPI.get_assign(socket, :theme, "light")
  ```
  """
  def get_assign(%Socket{} = socket, field, default \\ nil) when is_atom(field) do
    Map.get(socket.assigns, field, default)
  end

  @doc """
  Updates a resource in the socket assigns with the given values.

  ## Parameters

  - `socket` - The LiveView socket.
  - `resource` - The resource key in the socket assigns.
  - `values` - A map of field-value pairs to update.
  - `opts` - Options for the update operation.
    - `:validate` - Whether to validate the values before updating. Defaults to `true`.

  ## Returns

  - `{:ok, socket}` - If the update was successful.
  - `{:error, message, socket}` - If the update failed.

  ## Examples

  ```elixir
  # Update the user's settings
  case LiveViewAPI.update(socket, :user, %{role: "admin", active: true}) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
    
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
  ```
  """
  def update(%Socket{} = socket, resource, values, opts \\ [])
      when is_atom(resource) and is_map(values) do
    validate = Keyword.get(opts, :validate, true)

    if validate do
      case validate_resource_update(socket, resource, values) do
        {:ok, validated_values} ->
          resource_map = Map.get(socket.assigns, resource, %{})
          updated_resource = Map.merge(resource_map, validated_values)
          {:ok, Phoenix.Component.assign(socket, resource, updated_resource)}

        {:error, message} ->
          {:error, message, socket}
      end
    else
      resource_map = Map.get(socket.assigns, resource, %{})
      updated_resource = Map.merge(resource_map, values)
      {:ok, Phoenix.Component.assign(socket, resource, updated_resource)}
    end
  end

  @doc """
  Updates socket assigns directly with the given values.

  ## Parameters

  - `socket` - The LiveView socket.
  - `values` - A map of field-value pairs to update.
  - `opts` - Options for the update operation.
    - `:validate` - Whether to validate the values before updating. Defaults to `true`.

  ## Returns

  - `{:ok, socket}` - If the update was successful.
  - `{:error, message, socket}` - If the update failed.

  ## Examples

  ```elixir
  # Update multiple assigns at once
  case LiveViewAPI.update_assigns(socket, %{theme: "dark", sidebar_open: true}) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
    
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
  ```
  """
  def update_assigns(%Socket{} = socket, values, opts \\ []) when is_map(values) do
    validate = Keyword.get(opts, :validate, true)

    if validate do
      case validate_assigns_update(socket, values) do
        {:ok, validated_values} ->
          {:ok, Phoenix.Component.assign(socket, validated_values)}

        {:error, message} ->
          {:error, message, socket}
      end
    else
      {:ok, Phoenix.Component.assign(socket, values)}
    end
  end

  @doc """
  Creates a new resource in the socket assigns.

  ## Parameters

  - `socket` - The LiveView socket.
  - `resource` - The resource key in the socket assigns.
  - `values` - A map of field-value pairs for the resource.
  - `opts` - Options for the create operation.
    - `:validate` - Whether to validate the values before creating. Defaults to `true`.
    - `:replace` - Whether to replace an existing resource. Defaults to `false`.

  ## Returns

  - `{:ok, socket}` - If the create was successful.
  - `{:error, message, socket}` - If the create failed.

  ## Examples

  ```elixir
  # Create a new user resource
  case LiveViewAPI.create(socket, :user, %{id: "123", name: "John", role: "admin"}) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
    
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
  ```
  """
  def create(%Socket{} = socket, resource, values, opts \\ [])
      when is_atom(resource) and is_map(values) do
    validate = Keyword.get(opts, :validate, true)
    replace = Keyword.get(opts, :replace, false)

    # Check if resource already exists
    existing_resource = Map.get(socket.assigns, resource)

    cond do
      existing_resource != nil and not replace ->
        {:error, "Resource #{resource} already exists", socket}

      validate ->
        case validate_resource_create(socket, resource, values) do
          {:ok, validated_values} ->
            {:ok, Phoenix.Component.assign(socket, resource, validated_values)}

          {:error, message} ->
            {:error, message, socket}
        end

      true ->
        {:ok, Phoenix.Component.assign(socket, resource, values)}
    end
  end

  @doc """
  Removes a resource from the socket assigns.

  ## Parameters

  - `socket` - The LiveView socket.
  - `resource` - The resource key in the socket assigns.

  ## Returns

  - `{:ok, socket}` - The updated socket with the resource removed.

  ## Examples

  ```elixir
  # Remove the user resource
  {:ok, socket} = LiveViewAPI.remove(socket, :user)
  ```
  """
  def remove(%Socket{} = socket, resource) when is_atom(resource) do
    updated_assigns = Map.delete(socket.assigns, resource)
    {:ok, %Socket{socket | assigns: updated_assigns}}
  end

  @doc """
  Gets all resources from a socket's assigns that match a pattern.

  ## Parameters

  - `socket` - The LiveView socket.
  - `pattern` - A regex pattern to match against resource names.

  ## Returns

  A map of resource names to resource values.

  ## Examples

  ```elixir
  # Get all user-related resources
  user_resources = LiveViewAPI.get_resources(socket, ~r/^user_/)
  ```
  """
  def get_resources(%Socket{} = socket, pattern) when is_struct(pattern, Regex) do
    socket.assigns
    |> Enum.filter(fn {key, _value} -> Regex.match?(pattern, Atom.to_string(key)) end)
    |> Map.new()
  end

  @doc """
  Creates a resource in the socket assigns from a LiveViewResource module.

  ## Parameters

  - `socket` - The LiveView socket.
  - `resource_key` - The key to assign the resource to in the socket.
  - `resource_module` - The LiveViewResource module to use.
  - `values` - A map of values to initialize the resource with.
  - `opts` - Options for the create operation.
    - `:validate` - Whether to validate the values. Defaults to `true`.

  ## Returns

  - `{:ok, socket}` - If the create was successful.
  - `{:error, message, socket}` - If the create failed.

  ## Examples

  ```elixir
  defmodule MyApp.UserResource do
    use HydepwnsLiveview.Utils.LiveViewResource
    
    attributes do
      attribute :id, :string, required: true
      attribute :name, :string, required: true
    end
  end

  # Create a user resource from the module
  case LiveViewAPI.create_from_resource(socket, :user, MyApp.UserResource, %{id: "123", name: "John"}) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
    
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
  ```
  """
  def create_from_resource(%Socket{} = socket, resource_key, resource_module, values, opts \\ [])
      when is_atom(resource_key) and is_atom(resource_module) and is_map(values) do
    validate = Keyword.get(opts, :validate, true)

    if validate do
      # Generate type specs from the resource module
      type_specs = LiveViewResource.generate_type_specs(resource_module)

      # Validate values against type specs
      validation_results =
        Enum.map(values, fn {key, value} ->
          type_spec = Map.get(type_specs, key)

          if type_spec do
            case SocketValidator.validate_type(value, type_spec) do
              {:ok, _} -> nil
              {:error, message} -> message
            end
          else
            nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      if Enum.empty?(validation_results) do
        # Apply defaults for any missing required attributes
        schema = resource_module.__resource_schema__()

        defaults =
          schema.attributes
          |> Enum.filter(fn attr -> attr.default != nil end)
          |> Enum.map(fn attr -> {attr.name, attr.default} end)
          |> Map.new()

        # Merge defaults with provided values
        resource_with_defaults = Map.merge(defaults, values)

        {:ok, Phoenix.Component.assign(socket, resource_key, resource_with_defaults)}
      else
        error_message = Enum.join(validation_results, "; ")
        {:error, error_message, socket}
      end
    else
      {:ok, Phoenix.Component.assign(socket, resource_key, values)}
    end
  end

  # Private helper functions

  defp validate_resource_update(%Socket{} = _socket, _resource, values) do
    # This would ideally use the __resource_type_specs__/0 function from the LiveView module
    # For now, we'll just return :ok
    {:ok, values}
  end

  defp validate_assigns_update(%Socket{} = _socket, values) do
    # This would ideally use the type_specs information from the LiveView module
    # For now, we'll just return :ok
    {:ok, values}
  end

  defp validate_resource_create(%Socket{} = _socket, _resource, values) do
    # This would ideally use the __resource_type_specs__/0 function from the LiveView module
    # For now, we'll just return :ok
    {:ok, values}
  end
end
