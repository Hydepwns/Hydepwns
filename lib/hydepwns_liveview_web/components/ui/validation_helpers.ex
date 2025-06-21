defmodule HydepwnsLiveviewWeb.Components.UI.ValidationHelpers do
  @moduledoc """
  Helper functions for validation.
  """

  @doc """
  Validates a custom value against a validation function.
  """
  def validate_custom(value, validation_fn) when is_function(validation_fn, 1) do
    case validation_fn.(value) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
      true -> :ok
      false -> {:error, "Invalid value"}
      _ -> {:error, "Invalid validation result"}
    end
  end

  @doc """
  Validates a plan.
  """
  def validate_plan(plan) do
    validate_required_fields(plan) and validate_plan_structure(plan)
  end

  @doc """
  Validates a rule context.
  """
  def validate_rule_context(context, allowed_keys) do
    case context do
      context when is_map(context) ->
        invalid_keys = Map.keys(context) -- allowed_keys
        if Enum.empty?(invalid_keys) do
          :ok
        else
          {:error, "Invalid context keys: #{Enum.join(invalid_keys, ", ")}"}
        end
      _ -> {:error, "Context must be a map"}
    end
  end

  @doc """
  Validates a rule function.
  """
  def validate_rule_function(function) when is_function(function, 1) do
    :ok
  end
  def validate_rule_function(_) do
    {:error, "Rule must be a function that takes one argument"}
  end

  @doc """
  Validates a rule.
  """
  def validate_rule(rule, context) do
    validate_rule_function(rule) and validate_rule_context(context, [:resource, :user, :params])
  end

  @doc """
  Validates a socket key.
  """
  def validate_socket_key(key) when is_binary(key) do
    if String.length(key) > 0 do
      :ok
    else
      {:error, "Socket key cannot be empty"}
    end
  end
  def validate_socket_key(_) do
    {:error, "Socket key must be a string"}
  end

  @doc """
  Validates a socket.
  """
  def validate_socket(socket, required_keys) do
    case socket do
      %Phoenix.LiveView.Socket{} = _socket ->
        missing_keys = Enum.filter(required_keys, &(is_nil(socket.assigns[&1])))
        if Enum.empty?(missing_keys) do
          :ok
        else
          {:error, "Missing required socket assigns: #{Enum.join(missing_keys, ", ")}"}
        end
      _ -> {:error, "Invalid socket"}
    end
  end

  @doc """
  Validates that a value is one of the allowed values.
  """
  def validate_one_of(value, allowed_values) when is_list(allowed_values) do
    if value in allowed_values do
      :ok
    else
      {:error, "Value must be one of: #{Enum.join(allowed_values, ", ")}"}
    end
  end

  @doc """
  Validates a union type.
  """
  def validate_union(value, types) when is_list(types) do
    Enum.find_value(types, {:error, "Value does not match any of the allowed types"}, fn type ->
      case validate_type(value, type) do
        :ok -> :ok
        _ -> nil
      end
    end)
  end

  # Private helper functions

  defp validate_required_fields(plan) do
    required_fields = [:name, :steps]
    missing_fields = Enum.filter(required_fields, &(is_nil(plan[&1])))
    if Enum.empty?(missing_fields) do
      :ok
    else
      {:error, "Missing required fields: #{Enum.join(missing_fields, ", ")}"}
    end
  end

  defp validate_plan_structure(plan) do
    case plan do
      %{steps: steps} when is_list(steps) ->
        if Enum.all?(steps, &validate_step/1) do
          :ok
        else
          {:error, "Invalid step structure"}
        end
      _ -> {:error, "Invalid plan structure"}
    end
  end

  defp validate_step(step) do
    case step do
      %{type: type, action: action} when is_binary(type) and is_function(action, 1) -> true
      _ -> false
    end
  end

  defp validate_type(value, type) do
    type_validators = %{
      string: &is_binary/1,
      integer: &is_integer/1,
      float: &is_float/1,
      boolean: &is_boolean/1,
      list: &is_list/1,
      map: &is_map/1,
      atom: &is_atom/1,
      function: &is_function/1,
      pid: &is_pid/1,
      reference: &is_reference/1,
      port: &is_port/1,
      tuple: &is_tuple/1
    }

    case Map.get(type_validators, type) do
      nil -> {:error, "Invalid type"}
      validator -> if validator.(value), do: :ok, else: {:error, "Invalid type"}
    end
  end
end 