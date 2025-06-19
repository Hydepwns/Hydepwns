defmodule HydepwnsLiveviewWeb.Components.UI.GeneralHelpers do
  @moduledoc """
  General helper functions for UI components.
  """

  import Phoenix.Component
  import Phoenix.LiveView.Helpers

  @doc """
  Displays a field value with proper formatting.
  """
  def display_field_value(field, value) do
    case field do
      :datetime -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_datetime(value)
      :date -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_datetime(value)
      :time -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_time(value)
      :percentage -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_percentage(value)
      :size -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_size_change(value)
      :status -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_status(value)
      _ -> HydepwnsLiveviewWeb.Components.UI.FormatHelpers.format_value(value)
    end
  end

  @doc """
  Ensures a resource module exists and is loaded.
  """
  def ensure_resource_module(module_name) do
    case Code.ensure_loaded(module_name) do
      {:module, _} -> {:ok, module_name}
      {:error, :nofile} -> {:error, "Module #{module_name} does not exist"}
    end
  end

  @doc """
  Counts the number of errors in a list.
  """
  def error_count(errors) when is_list(errors) do
    Enum.count(errors)
  end
  def error_count(_), do: 0

  @doc """
  Returns the appropriate icon for an error level.
  """
  def error_icon(level) do
    HydepwnsLiveviewWeb.Components.UI.ComponentHelpers.render_icon(level)
  end

  @doc """
  Gets the error ID from an error struct.
  """
  def get_error_id(error) do
    case error do
      %{id: id} -> id
      %{error_id: id} -> id
      _ -> nil
    end
  end

  @doc """
  Gets the error message from an error struct.
  """
  def get_error_message(error) do
    case error do
      %{message: message} -> message
      %{error: error} -> get_error_message(error)
      error when is_binary(error) -> error
      _ -> "Unknown error"
    end
  end

  @doc """
  Gets the error module from an error struct.
  """
  def get_error_module(error) do
    case error do
      %{module: module} -> module
      %{error_module: module} -> module
      _ -> nil
    end
  end

  @doc false
  def get_transformation_name(transformation) do
    case transformation do
      %{name: name} -> name
      %{transformation_name: name} -> name
      _ -> "Unknown transformation"
    end
  end

  @doc """
  Finds the most affected view from a list of errors.
  """
  def most_affected_view(errors) do
    errors
    |> Enum.group_by(&get_error_module/1)
    |> Enum.max_by(fn {_module, module_errors} -> length(module_errors) end, fn -> {nil, []} end)
    |> elem(0)
  end

  @doc """
  Finds the most common error type from a list of errors.
  """
  def most_common_error_type(errors) do
    errors
    |> Enum.group_by(&get_error_type/1)
    |> Enum.max_by(fn {_type, type_errors} -> length(type_errors) end, fn -> {nil, []} end)
    |> elem(0)
  end

  @doc """
  Gets the relationship name from a relationship definition.
  """
  def relationship_name_from_def(def) do
    case def do
      %{name: name} -> name
      %{relationship_name: name} -> name
      _ -> "Unknown relationship"
    end
  end

  @doc """
  Renders errors in a formatted way.
  """
  def render_errors(assigns) do
    ~H"""
    <div class={"error-container #{@level}"}>
      <h3 class="error-title"><%= @title %></h3>
      <ul class="error-list">
        <%= for error <- @errors do %>
          <li class="error-item"><%= error %></li>
        <% end %>
      </ul>
    </div>
    """
  end

  @doc false
  def render_metrics_detail(assigns) do
    ~H"""
    <div class="metrics-detail">
      <%= for detail <- @metrics.details do %>
        <div class="detail-item">
          <h4 class="detail-title"><%= detail.title %></h4>
          <div class="detail-content">
            <%= detail.content %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc false
  def render_performance_summary(assigns) do
    ~H"""
    <div class="performance-summary">
      <%= for summary <- @metrics.summaries do %>
        <div class="summary-item">
          <h4 class="summary-title"><%= summary.title %></h4>
          <div class="summary-content">
            <%= summary.content %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders validation status.
  """
  def render_validation_status(assigns) do
    ~H"""
    <div class="validation-status">
      <%= for status <- @validation.statuses do %>
        <div class="status-item">
          <h4 class="status-title"><%= status.title %></h4>
          <div class="status-content">
            <%= status.content %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Returns a shortened version of a view name.
  """
  def short_view_name(name) do
    name
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.replace("View", "")
  end

  @doc """
  Returns the appropriate icon for a status.
  """
  def status_icon(status) do
    case status do
      "success" -> "✓"
      "error" -> "✗"
      "warning" -> "!"
      "info" -> "i"
      _ -> "•"
    end
  end

  @doc """
  Truncates a message to a specified length.
  """
  def truncate_message(message, length) when is_binary(message) do
    if String.length(message) > length do
      String.slice(message, 0, length) <> "..."
    else
      message
    end
  end
  def truncate_message(message, _), do: message

  @doc """
  Returns a list of unique error types from a list of errors.
  """
  def unique_error_types(errors) do
    errors
    |> Enum.map(&get_error_type/1)
    |> Enum.uniq()
  end

  @doc """
  Unsets default status for all items except the given ID.
  """
  def unset_other_defaults(items, except_id) do
    Enum.map(items, fn item ->
      if item.id == except_id do
        Map.put(item, :is_default, true)
      else
        Map.put(item, :is_default, false)
      end
    end)
  end

  # Private helper functions

  defp get_error_type(error) do
    case error do
      %{type: type} -> type
      %{error_type: type} -> type
      _ -> :unknown
    end
  end
end 