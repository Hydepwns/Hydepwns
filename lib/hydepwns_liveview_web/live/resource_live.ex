defmodule HydepwnsLiveviewWeb.ResourceLive do
  @moduledoc """
  Enhanced LiveView module with resource-oriented socket assigns.

  This module extends BaseLive by adding support for declarative socket assigns
  using an Ash-inspired DSL pattern. It allows LiveViews to define their socket 
  assigns as first-class resources with attributes, validations, and relationships.

  ## Features

  - Declarative socket schema specification using `assigns do ... end` DSL
  - Resource-oriented socket assigns
  - Automatic validation of socket assigns
  - API-based access patterns

  ## Usage

  ```elixir
  defmodule MyAppWeb.UserLive do
    use HydepwnsLiveviewWeb.ResourceLive
    
    assigns do
      attribute :user_id, :string, required: true
      attribute :username, :string, required: true
      attribute :role, {:one_of, ["admin", "user", "guest"]}, default: "user"
      
      # Nested attributes using map schema
      attribute :settings, :map do
        attribute :theme, {:one_of, ["dark", "light", "system"]}, default: "system"
        attribute :notifications, :boolean, default: true
      end
      
      # Relationships to other resources
      relationship :team, :belongs_to, MyApp.TeamResource
      relationship :posts, :has_many, MyApp.PostResource
    end
    
    def do_mount(params, session, socket) do
      # Your mount logic here
      {:ok, assign(socket, :user_id, "123")}
    end
    
    # Your LiveView implementation...
  end
  ```
  """

  alias HydepwnsLiveview.Utils.LiveViewAPI
  alias HydepwnsLiveview.Utils.SocketValidator
  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Events.Event

  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Resources")
     |> assign(:resources, ResourceSystem.list_resources())}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    case ResourceSystem.get_resource(id) do
      {:ok, resource} ->
        all_resources = ResourceSystem.list_resources()
        child_resources = Enum.filter(all_resources, fn r -> r.parent_id == resource.id end)

        {:noreply,
         socket
         |> assign(:resource, resource)
         |> assign(:page_title, "Resource: #{resource.name}")
         |> assign(:parent_resource, get_parent_resource(resource.parent_id))
         |> assign(:child_resources, child_resources)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Resource not found")
         |> redirect(to: ~p"/resources")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_resource", %{"id" => id}, socket) do
    case ResourceSystem.delete_resource(id) do
      {:ok, _} ->
        Event.create("resource.deleted", %{resource_id: id})

        {:noreply,
         socket
         |> put_flash(:info, "Resource deleted successfully")
         |> redirect(to: ~p"/resources")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete resource: #{reason}")}
    end
  end

  defp get_parent_resource(nil), do: nil

  defp get_parent_resource(parent_id) do
    case ResourceSystem.get_resource(parent_id) do
      {:ok, resource} -> resource
      {:error, _} -> nil
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div :if={@live_action == :index} class="space-y-8">
        <div class="flex justify-between items-center">
          <h1 class="text-3xl font-bold">Resources</h1>
          <.link navigate={~p"/resources/new"} class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            New Resource
          </.link>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for resource <- @resources do %>
            <div class="border rounded-lg p-4 shadow-sm">
              <h2 class="text-xl font-semibold mb-2">{resource.name}</h2>
              <p class="text-gray-600 mb-4">{resource.description}</p>
              <div class="flex flex-wrap gap-2">
                <.link navigate={~p"/resources/#{resource.id}/edit"} class="text-blue-600 hover:text-blue-800" data-test-id={"edit-resource-#{resource.id}"}>
                  Edit
                </.link>
                <.link navigate={~p"/resources/#{resource.id}/subscriptions"} class="text-blue-600 hover:text-blue-800" data-test-id={"manage-subscriptions-#{resource.id}"}>
                  Manage Subscriptions
                </.link>
                <.link navigate={~p"/resources/#{resource.id}/events"} class="text-blue-600 hover:text-blue-800" data-test-id={"view-events-#{resource.id}"}>
                  View Events
                </.link>
                <button phx-click="delete_resource" phx-value-id={resource.id} data-confirm="Are you sure you want to delete this resource?" class="text-red-600 hover:text-red-800" data-test-id={"delete-resource-#{resource.id}"}>
                  Delete Resource
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <div :if={@live_action == :show} class="space-y-8">
        <div class="flex justify-between items-center">
          <h1 class="text-3xl font-bold">{@resource.name}</h1>
          <div class="flex gap-4">
            <.link navigate={~p"/resources/#{@resource.id}/edit"} class="bg-yellow-500 hover:bg-yellow-600 text-white font-bold py-2 px-4 rounded">
              Edit
            </.link>
            <button phx-click="delete_resource" phx-value-id={@resource.id} data-confirm="Are you sure you want to delete this resource?" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded">
              Delete Resource
            </button>
          </div>
        </div>

        <div class="bg-white shadow-lg rounded-lg p-6">
          <div class="space-y-4">
            <div>
              <h2 class="text-xl font-semibold mb-2">Description</h2>
              <p class="text-gray-600">{@resource.description}</p>
            </div>

            <div>
              <h2 class="text-xl font-semibold mb-2">Type</h2>
              <p class="text-gray-600">{@resource.type}</p>
            </div>

            <div>
              <h2 class="text-xl font-semibold mb-2">Status</h2>
              <p class="text-gray-600">{@resource.status}</p>
            </div>

            <div :if={@parent_resource} class="relationship-row parent-resource">
              <h2 class="text-xl font-semibold mb-2">Parent Resource</h2>
              <.link navigate={~p"/resources/#{@parent_resource.id}"} class="text-blue-600 hover:text-blue-800">
                {@parent_resource.name}
              </.link>
            </div>

            <div :if={@child_resources && @child_resources != []}>
              <h2 class="text-xl font-semibold mb-2">Child Resources</h2>
              <div>
                <%= for child <- @child_resources do %>
                  <div class="child-resource">
                    <.link navigate={~p"/resources/#{child.id}"} class="text-blue-600 hover:text-blue-800">
                      {child.name}
                    </.link>
                  </div>
                <% end %>
              </div>
              <div class="relationship-count">
                {length(@child_resources)}
              </div>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div class="bg-white shadow-lg rounded-lg p-6">
            <h2 class="text-xl font-semibold mb-4">Events</h2>
            <.link navigate={~p"/resources/#{@resource.id}/events"} class="text-blue-600 hover:text-blue-800">
              View All Events
            </.link>
          </div>

          <div class="bg-white shadow-lg rounded-lg p-6">
            <h2 class="text-xl font-semibold mb-4">Subscriptions</h2>
            <.link navigate={~p"/resources/#{@resource.id}/subscriptions"} class="text-blue-600 hover:text-blue-800">
              Manage Subscriptions
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defmacro __using__(_opts) do
    quote do
      use HydepwnsLiveviewWeb.BaseLive
      import HydepwnsLiveviewWeb.ResourceLive
      import Phoenix.LiveView
      import Phoenix.LiveView.Helpers
      alias HydepwnsLiveview.Utils.LiveViewAPI

      Module.register_attribute(__MODULE__, :resource_attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :resource_relationships, accumulate: true)

      @before_compile HydepwnsLiveviewWeb.ResourceLive

      # Define do_mount before making it overridable
      def do_mount(params, session, socket) do
        socket
      end

      # Default implementation of do_mount to be overridden
      defoverridable do_mount: 3

      # Resource API Methods
      def get_resource(socket, field, default \\ nil) do
        LiveViewAPI.get(socket, field, default)
      end

      def update_resource(socket, resource_key, updates) do
        # Validate updates against the resource definition
        case validate_updates(socket, resource_key, updates) do
          {:ok, validated_updates} ->
            # Apply the validated updates
            socket = Phoenix.Component.assign(socket, validated_updates)
            {:ok, socket}

          {:error, message} ->
            # Log the validation error
            require Logger
            Logger.warning("Resource update validation failed: #{message}")

            # Return error with original socket
            {:error, message, socket}
        end
      end

      def validate_updates(socket, _resource_key, updates) do
        # Extract type specifications from metadata
        type_specs = __resource_type_specs__()

        # Check each update against its type specification
        validation_results =
          for {key, value} <- updates, Map.has_key?(type_specs, key) do
            type_spec = Map.get(type_specs, key)
            SocketValidator.validate_type(value, type_spec)
          end

        # Check if any validations failed
        errors =
          validation_results
          |> Enum.filter(fn
            {:error, _} -> true
            _ -> false
          end)
          |> Enum.map(fn {:error, message} -> message end)

        if Enum.empty?(errors) do
          {:ok, updates}
        else
          {:error, Enum.join(errors, "; ")}
        end
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __resource_metadata__ do
        %{
          attributes: @resource_attributes,
          relationships: @resource_relationships
        }
      end

      def __resource_type_specs__ do
        attrs =
          @resource_attributes
          |> Enum.map(fn attr ->
            {attr.name, attr.type}
          end)
          |> Map.new()

        attrs
      end
    end
  end

  @doc """
  DSL for defining assigns in a resource-oriented LiveView.

  ## Example

  ```elixir
  assigns do
    attribute :user_id, :string, required: true
    attribute :name, :string, required: true
    
    # Nested attributes
    attribute :settings, :map do
      attribute :theme, {:one_of, ["light", "dark"]}, default: "dark"
      attribute :notifications, :boolean, default: true
    end
    
    # Relationships
    relationship :team, :belongs_to, MyApp.TeamResource
    relationship :posts, :has_many, MyApp.PostResource
  end
  ```
  """
  defmacro assigns(do: block) do
    quote do
      unquote(block)

      # The do_mount defined in __using__ is defoverridable.
      # The user should implement do_mount in their LiveView.
      # Default setting logic will be handled by a helper function called by the user's do_mount.

      defp __apply_resource_defaults__(socket) do
        defaults =
          @resource_attributes
          |> Enum.filter(fn attr -> Map.has_key?(attr, :default) && attr.default != nil end)
          |> Enum.map(fn attr -> {attr.name, attr.default} end)
          |> Map.new()

        Phoenix.Component.assign(socket, defaults)
      end
    end
  end

  @doc """
  DSL for defining a single attribute in a resource-oriented LiveView.
  """
  defmacro attribute(name, type, opts \\ [], do_block \\ nil) do
    opts = Macro.escape(opts)

    quote bind_quoted: [
            name: name,
            type: type,
            opts: opts,
            do_block: Macro.escape(do_block, unquote: true)
          ] do
      attr_def = %{
        name: name,
        type: type,
        required: Keyword.get(opts, :required, false),
        default: Keyword.get(opts, :default, nil),
        nested_attributes: nil
      }

      # Handle nested attributes if a do block is provided
      if do_block do
        nested_attrs =
          case do_block do
            {:__block__, _, attrs} -> attrs
            attr -> [attr]
          end

        # Process nested attributes (simplified for now)
        attr_def = Map.put(attr_def, :nested_attributes, nested_attrs)
      end

      @resource_attributes attr_def
    end
  end

  @doc """
  DSL for defining a relationship to another resource.
  """
  defmacro relationship(name, type, resource, opts \\ []) do
    opts = Macro.escape(opts)

    quote bind_quoted: [name: name, type: type, resource: resource, opts: opts] do
      relationship_def = %{
        name: name,
        type: type,
        resource: resource,
        foreign_key: Keyword.get(opts, :foreign_key, nil)
      }

      @resource_relationships relationship_def
    end
  end
end
