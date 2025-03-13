defmodule HydepwnsLiveview.Examples.TransformationMetricsExampleLive do
  @moduledoc """
  Example LiveView that demonstrates the TransformationMetricsViewer component.

  This LiveView allows users to:
  1. Run example transformations to generate metrics
  2. View metrics in different visualization modes
  3. Filter and analyze transformation performance
  """

  use Phoenix.LiveView
  alias HydepwnsLiveview.Components.TransformationMetricsViewer
  alias HydepwnsLiveview.Utils.TransformationPipeline

  # Example transformations for demonstration
  defmodule ExampleTransformations do
    defmodule NormalizeEmail do
      @moduledoc "Normalizes email addresses to lowercase"

      def transform(resource, _context) do
        if Map.has_key?(resource, :email) && resource.email do
          # Simulate some processing time
          :timer.sleep(:rand.uniform(50))
          {:ok, Map.update!(resource, :email, &String.downcase/1)}
        else
          {:ok, resource}
        end
      end

      def info do
        %{
          name: "Normalize Email",
          description: "Normalizes email addresses to lowercase",
          version: "1.0",
          categories: [:email, :normalization]
        }
      end
    end

    defmodule ValidateEmail do
      @moduledoc "Validates email format"

      def transform(resource, _context) do
        if Map.has_key?(resource, :email) && resource.email do
          # Simulate some processing time
          :timer.sleep(:rand.uniform(100))

          if String.contains?(resource.email, "@") do
            {:ok, resource}
          else
            {:error, "Invalid email format"}
          end
        else
          {:ok, resource}
        end
      end

      def info do
        %{
          name: "Validate Email",
          description: "Validates email format",
          version: "1.0",
          categories: [:email, :validation]
        }
      end
    end

    defmodule GenerateUsername do
      @moduledoc "Generates a username from name if not present"

      def transform(resource, _context) do
        if Map.has_key?(resource, :name) && resource.name && !Map.has_key?(resource, :username) do
          # Simulate some processing time
          :timer.sleep(:rand.uniform(150))

          username =
            resource.name
            |> String.downcase()
            |> String.replace(~r/[^a-z0-9]/, "")

          {:ok, Map.put(resource, :username, username)}
        else
          {:ok, resource}
        end
      end

      def info do
        %{
          name: "Generate Username",
          description: "Generates a username from name if not present",
          version: "1.0",
          categories: [:user, :generation]
        }
      end
    end

    defmodule AddTimestamp do
      @moduledoc "Adds a timestamp to the resource"

      def transform(resource, _context) do
        # Simulate some processing time
        :timer.sleep(:rand.uniform(30))

        {:ok, Map.put(resource, :timestamp, DateTime.utc_now())}
      end

      def info do
        %{
          name: "Add Timestamp",
          description: "Adds a timestamp to the resource",
          version: "1.0",
          categories: [:metadata, :timestamp]
        }
      end
    end
  end

  def mount(_params, _session, socket) do
    # Create a pipeline with our example transformations
    pipeline =
      TransformationPipeline.new(
        name: "User Processing Pipeline",
        description: "Processes user data for storage"
      )
      |> TransformationPipeline.add(ExampleTransformations.NormalizeEmail)
      |> TransformationPipeline.add(ExampleTransformations.ValidateEmail)
      |> TransformationPipeline.add(ExampleTransformations.GenerateUsername)
      |> TransformationPipeline.add(ExampleTransformations.AddTimestamp)

    # Sample resources for transformation
    sample_resources = [
      %{name: "John Doe", email: "JOHN@EXAMPLE.COM"},
      %{name: "Jane Smith", email: "jane.smith@example.com"},
      %{name: "Bob Johnson", email: "bob@example"},
      %{name: "Alice Brown", email: "ALICE.BROWN@EXAMPLE.COM"}
    ]

    {:ok,
     socket
     |> assign(:pipeline, pipeline)
     |> assign(:sample_resources, sample_resources)
     |> assign(:selected_resource, List.first(sample_resources))
     |> assign(:transformation_results, [])
     |> assign(:error_message, nil)}
  end

  def handle_event("select-resource", %{"index" => index}, socket) do
    index = String.to_integer(index)
    selected_resource = Enum.at(socket.assigns.sample_resources, index)

    {:noreply, assign(socket, :selected_resource, selected_resource)}
  end

  def handle_event("run-transformation", _, socket) do
    # Apply the pipeline to the selected resource
    case TransformationPipeline.apply(
           socket.assigns.pipeline,
           socket.assigns.selected_resource,
           collect_metrics: true
         ) do
      {:ok, transformed_resource} ->
        # Add to transformation results
        results = [
          %{
            original: socket.assigns.selected_resource,
            transformed: transformed_resource,
            timestamp: DateTime.utc_now(),
            status: :success
          }
          | socket.assigns.transformation_results
        ]

        {:noreply,
         socket
         |> assign(:transformation_results, results)
         |> assign(:error_message, nil)}

      {:error, error} ->
        # Add to transformation results with error
        results = [
          %{
            original: socket.assigns.selected_resource,
            transformed: error.last_resource,
            timestamp: DateTime.utc_now(),
            status: :error,
            error: error
          }
          | socket.assigns.transformation_results
        ]

        {:noreply,
         socket
         |> assign(:transformation_results, results)
         |> assign(:error_message, "Transformation failed: #{inspect(error.message)}")}
    end
  end

  def handle_event("clear-results", _, socket) do
    {:noreply, assign(socket, :transformation_results, [])}
  end

  def render(assigns) do
    ~H"""
    <div class="transformation-metrics-example">
      <h1>Transformation Metrics Example</h1>

      <div class="example-container">
        <div class="control-panel">
          <h2>Run Transformations</h2>

          <div class="resource-selector">
            <h3>Select a Resource</h3>
            <div class="resource-list">
              <%= for {resource, index} <- Enum.with_index(@sample_resources) do %>
                <div class={"resource-item #{if @selected_resource == resource, do: "selected"}"} phx-click="select-resource" phx-value-index={index}>
                  <div class="resource-name">{resource.name}</div>
                  <div class="resource-email">{resource.email}</div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="action-buttons">
            <button class="run-button" phx-click="run-transformation">
              Run Transformation
            </button>
            <button class="clear-button" phx-click="clear-results">
              Clear Results
            </button>
          </div>

          <%= if @error_message do %>
            <div class="error-message">
              {@error_message}
            </div>
          <% end %>

          <div class="results-panel">
            <h3>Transformation Results</h3>
            <div class="results-list">
              <%= for result <- @transformation_results do %>
                <div class={"result-item #{result.status}"}>
                  <div class="result-timestamp">
                    {Calendar.strftime(result.timestamp, "%H:%M:%S")}
                  </div>
                  <div class="result-status">
                    {if result.status == :success, do: "✅", else: "❌"}
                  </div>
                  <div class="result-content">
                    <div class="original">
                      <strong>Original:</strong> {inspect(result.original)}
                    </div>
                    <div class="transformed">
                      <strong>Result:</strong> {inspect(result.transformed)}
                    </div>
                  </div>
                </div>
              <% end %>

              <%= if Enum.empty?(@transformation_results) do %>
                <div class="empty-results">
                  No transformations run yet. Click "Run Transformation" to start.
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="metrics-panel">
          <.live_component module={TransformationMetricsViewer} id="transformation-metrics-viewer" />
        </div>
      </div>
    </div>
    """
  end
end
