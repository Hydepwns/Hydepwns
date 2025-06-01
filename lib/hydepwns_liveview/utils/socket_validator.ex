defmodule HydepwnsLiveview.Utils.SocketValidator do
  @moduledoc """
  Provides utilities for validating LiveView socket assigns.
  Helps prevent KeyErrors and ensures required parameters exist.
  """

  require Logger

  @doc """
  Ensures all required assigns are present in the socket.
  Returns {:ok, socket} or {:error, missing_keys}
  """
  @spec validate_required(Phoenix.LiveView.Socket.t(), list(atom())) ::
          {:ok, Phoenix.LiveView.Socket.t()} | {:error, list(atom())}
  def validate_required(socket, required_keys) when is_list(required_keys) do
    missing = Enum.filter(required_keys, fn key -> !Map.has_key?(socket.assigns, key) end)

    if Enum.empty?(missing) do
      {:ok, socket}
    else
      # Report telemetry for missing required keys
      :telemetry.execute(
        [:hydepwns, :socket_validator, :validation, :missing_assigns],
        %{count: length(missing)},
        %{
          missing_keys: missing,
          view_module: Map.get(socket.assigns, :view, "unknown"),
          validation_type: :required
        }
      )

      # Broadcast to pub/sub for debug panel (only in dev)
      if Mix.env() == :dev do
        error_data = %{
          key:
            case missing do
              [h | _] -> h
              _ -> nil
            end,
          type: "missing_assigns",
          message: "Missing required assigns: #{inspect(missing)}",
          details: %{
            missing_keys: missing,
            view_module: Map.get(socket.assigns, :view, "unknown")
          }
        }

        broadcast_validation_error(
          Map.get(socket.assigns, :view, "unknown"),
          "missing_assigns",
          "Missing required assigns: #{inspect(missing)}",
          error_data
        )
      end

      {:error, missing}
    end
  end

  @doc """
  Validates a value against a type specification.
  Returns {:ok, value} or {:error, message}
  """
  @spec validate_type(any(), any()) :: {:ok, any()} | {:error, String.t()}
  def validate_type(value, :string) when is_binary(value), do: {:ok, value}
  def validate_type(_value, :string), do: {:error, "expected string"}

  def validate_type(value, :integer) when is_integer(value), do: {:ok, value}
  def validate_type(_value, :integer), do: {:error, "expected integer"}

  def validate_type(value, :boolean) when is_boolean(value), do: {:ok, value}
  def validate_type(_value, :boolean), do: {:error, "expected boolean"}

  def validate_type(value, :map) when is_map(value), do: {:ok, value}
  def validate_type(_value, :map), do: {:error, "expected map"}

  def validate_type(value, :list) when is_list(value), do: {:ok, value}
  def validate_type(_value, :list), do: {:error, "expected list"}

  def validate_type(value, :atom) when is_atom(value), do: {:ok, value}
  def validate_type(_value, :atom), do: {:error, "expected atom"}

  def validate_type(value, :function) when is_function(value), do: {:ok, value}
  def validate_type(_value, :function), do: {:error, "expected function"}

  def validate_type(value, :float) when is_float(value), do: {:ok, value}
  def validate_type(_value, :float), do: {:error, "expected float"}

  def validate_type(value, :number) when is_number(value), do: {:ok, value}
  def validate_type(_value, :number), do: {:error, "expected number (integer or float)"}

  # Complex type validations
  def validate_type(value, {:list, type_spec}) when is_list(value) do
    if value == [] do
      {:ok, value}
    else
      errors =
        Enum.with_index(value)
        |> Enum.reduce([], fn {element, index}, acc ->
          case validate_type(element, type_spec) do
            {:ok, _} ->
              acc

            {:error, message} ->
              # If the error is a schema or list validation, flatten it
              cond do
                String.starts_with?(message, "schema validation failed: ") ->
                  nested_error_details = String.slice(message, 26..-1//1)

                  nested_error_details
                  |> String.split("; ")
                  |> Enum.map(fn sub_error -> "item at index #{index}.#{sub_error}" end)
                  |> then(&(acc ++ &1))

                String.starts_with?(message, "list validation failed: ") ->
                  nested_error_details = String.slice(message, 22..-1//1)

                  nested_error_details
                  |> String.split("; ")
                  |> Enum.map(fn sub_error -> "item at index #{index}.#{sub_error}" end)
                  |> then(&(acc ++ &1))

                true ->
                  acc ++ ["item at index #{index}: #{message}"]
              end
          end
        end)

      if Enum.empty?(errors) do
        {:ok, value}
      else
        {:error, Enum.join(errors, "; ")}
      end
    end
  end

  def validate_type(_value, {:list, _type_spec}), do: {:error, "expected list"}

  def validate_type(value, {:one_of, allowed}) when is_list(allowed) do
    if Enum.member?(allowed, value) do
      {:ok, value}
    else
      {:error, "expected one of #{inspect(allowed)}, got: #{inspect(value)}"}
    end
  end

  def validate_type(value, {:union, types}) when is_list(types) do
    results = Enum.map(types, fn type -> {type, validate_type(value, type)} end)

    if Enum.any?(results, fn {_, result} -> match?({:ok, _}, result) end) do
      {:ok, value}
    else
      error_details =
        Enum.map_join(results, "\n", fn {type, {:error, msg}} ->
          "- For #{inspect(type)}: #{msg}"
        end)

      {:error, "Value matched none of the union types:\n#{error_details}"}
    end
  end

  def validate_type(value, {:custom, validator}) when is_function(validator, 1) do
    case validator.(value) do
      true -> {:ok, value}
      false -> {:error, "custom validation failed"}
      {:error, message} -> {:error, message}
      other -> {:error, "custom validator returned unexpected result: #{inspect(other)}"}
    end
  end

  def validate_type(value, {:map, schema}) when is_map(value) and is_map(schema) do
    errors =
      Enum.reduce(schema, [], fn {key, type_spec}, acc ->
        current_path_segment = Atom.to_string(key)

        if Map.has_key?(value, key) do
          case validate_type(Map.get(value, key), type_spec) do
            {:ok, _} ->
              acc

            {:error, message} ->
              new_errors =
                cond do
                  String.starts_with?(message, "schema validation failed: ") ->
                    nested_error_details = String.slice(message, 26..-1//1)

                    nested_error_details
                    |> String.split("; ")
                    |> Enum.map(fn sub_error -> "#{current_path_segment}.#{sub_error}" end)

                  String.starts_with?(message, "list validation failed: ") ->
                    nested_error_details = String.slice(message, 22..-1//1)

                    nested_error_details
                    |> String.split("; ")
                    |> Enum.map(fn sub_error -> "#{current_path_segment}.#{sub_error}" end)

                  true ->
                    ["#{current_path_segment}: #{message}"]
                end

              acc ++ new_errors
          end
        else
          case type_spec do
            {:optional, _} -> acc
            _ -> acc ++ ["#{current_path_segment}: missing field"]
          end
        end
      end)

    if Enum.empty?(errors) do
      {:ok, value}
    else
      {:error, Enum.join(errors, "; ")}
    end
  end

  def validate_type(_value, {:map, _schema}), do: {:error, "expected map"}

  def validate_type(nil, {:optional, _type_spec}), do: {:ok, nil}

  def validate_type(value, {:optional, map_schema})
      when is_map(map_schema) and not is_struct(map_schema) do
    validate_type(value, {:optional, {:map, map_schema}})
  end

  def validate_type(value, {:optional, type_spec}) do
    validate_type(value, type_spec)
  end

  def validate_type(value, {:nested_list, type_spec}) when is_list(value) do
    if value == [] do
      Logger.warning(
        "[validate_type] Received empty outer list for nested_list type_spec: #{inspect(type_spec)}"
      )

      # Return error for empty outer list unless type_spec is :any or :optional
      case type_spec do
        :any ->
          {:ok, value}

        {:optional, _} ->
          {:ok, value}

        _ ->
          {:error,
           "outer list is empty, expected at least one sublist of type #{inspect(type_spec)}"}
      end
    else
      outer_errors =
        Enum.with_index(value)
        |> Enum.reduce([], fn {sublist, outer_idx}, acc_outer ->
          if is_list(sublist) do
            if sublist == [] do
              Logger.warning(
                "[validate_type] Received empty sublist at index #{outer_idx} for nested_list type_spec: #{inspect(type_spec)}"
              )

              # Return error for empty sublist unless type_spec is :any or :optional
              case type_spec do
                :any ->
                  acc_outer

                {:optional, _} ->
                  acc_outer

                _ ->
                  acc_outer ++
                    [
                      "sublist at index #{outer_idx} is empty, expected at least one element of type #{inspect(type_spec)}"
                    ]
              end
            else
              inner_errors =
                Enum.with_index(sublist)
                |> Enum.reduce([], fn {element, inner_idx}, acc_inner ->
                  case validate_type(element, type_spec) do
                    {:ok, _} ->
                      acc_inner

                    {:error, msg} ->
                      acc_inner ++
                        ["sublist at index #{outer_idx}, item at index #{inner_idx}: #{msg}"]
                  end
                end)

              acc_outer ++ inner_errors
            end
          else
            acc_outer ++ ["item at index #{outer_idx}: expected a list, got #{inspect(sublist)}"]
          end
        end)

      if Enum.empty?(outer_errors) do
        {:ok, value}
      else
        {:error, "nested_list validation failed: #{Enum.join(outer_errors, "; ")}"}
      end
    end
  end

  def validate_type(_value, {:nested_list, _type_spec}), do: {:error, "expected nested list"}

  def validate_type(value, {:list_of_maps, schema}) when is_list(value) do
    if value == [] do
      Logger.warning(
        "[validate_type] Received empty list for list_of_maps schema: #{inspect(schema)}"
      )
    end

    errors =
      Enum.with_index(value)
      |> Enum.reduce([], fn {map, index}, acc ->
        case validate_type(map, {:map, schema}) do
          {:ok, _} -> acc
          {:error, message} -> acc ++ ["item at index #{index}: #{message}"]
        end
      end)

    if Enum.empty?(errors) do
      {:ok, value}
    else
      {:error, "list_of_maps validation failed: #{Enum.join(errors, "; ")}"}
    end
  end

  def validate_type(_value, {:list_of_maps, _schema}), do: {:error, "expected list of maps"}

  def validate_type(value, {:map_with_lists, schema}) when is_map(value) and is_map(schema) do
    errors =
      Enum.reduce(schema, [], fn {key, type_spec}, acc ->
        if Map.has_key?(value, key) do
          case validate_type(Map.get(value, key), type_spec) do
            {:ok, _} -> acc
            {:error, message} -> acc ++ ["#{key}: #{message}"]
          end
        else
          acc ++ ["#{key}: required key missing"]
        end
      end)

    if Enum.empty?(errors) do
      {:ok, value}
    else
      {:error, "map_with_lists validation failed: #{Enum.join(errors, "; ")}"}
    end
  end

  def validate_type(_value, {:map_with_lists, _schema}), do: {:error, "expected map"}

  # NEW CLAUSE: Handle direct map schema if schema itself is a map (and not a struct)
  def validate_type(value, schema) when is_map(schema) and not is_struct(schema) do
    validate_type(value, {:map, schema})
  end

  # Default case for unrecognized type specs (must be last)
  def validate_type(_value, type_spec) do
    {:error, "unsupported type specification: #{inspect(type_spec)}"}
  end

  @doc """
  Gets a value from socket assigns with a default fallback
  """
  @spec get_assign(Phoenix.LiveView.Socket.t(), atom(), any()) :: any()
  def get_assign(socket, key, default \\ nil) do
    Map.get(socket.assigns, key, default)
  end

  @doc """
  Safely updates socket assigns, ensuring required fields are maintained
  """
  @spec safe_assign(Phoenix.LiveView.Socket.t(), map(), list(atom())) ::
          {:ok, Phoenix.LiveView.Socket.t()} | {:error, String.t(), Phoenix.LiveView.Socket.t()}
  def safe_assign(socket, assigns, required_keys \\ []) do
    socket =
      Enum.reduce(Map.to_list(assigns), socket, fn {key, value}, acc ->
        Phoenix.Component.assign(acc, key, value)
      end)

    case validate_required(socket, required_keys) do
      {:ok, socket} -> {:ok, socket}
      {:error, missing} -> {:error, "Missing required assigns: #{inspect(missing)}", socket}
    end
  end

  @doc """
  Validates that an assign is of the expected type.

  ## Type Specifications

  Basic types:
  - `:string` - Value must be a binary string
  - `:integer` - Value must be an integer
  - `:boolean` - Value must be a boolean (true or false)
  - `:map` - Value must be a map
  - `:list` - Value must be a list
  - `:atom` - Value must be an atom
  - `:function` - Value must be a function

  Complex types:
  - `{:list, type_spec}` - A list where all elements match the given type_spec
  - `{:map, schema}` - A map that matches the given schema structure
  - `{:one_of, [val1, val2, ...]}` - Value must be one of the allowed values (enum)
  - `{:union, [type1, type2, ...]}` - Value must match one of the specified types
  - `{:custom, validation_function}` - Value must pass the custom validation function
  - `{:optional, type_spec}` - Field is optional but must match type_spec if present
  - `{:nested_list, type_spec}` - Deeply nested list validation
  - `{:list_of_maps, schema}` - List where each element is a map matching the schema

  ## Examples

  ```elixir
  # Basic type validation
  SocketValidator.type_validation(socket, :count, :integer)

  # List validation
  SocketValidator.type_validation(socket, :tags, {:list, :string})

  # Map validation with schema
  SocketValidator.type_validation(socket, :user, %{name: :string, age: :integer})

  # Nested map validation
  SocketValidator.type_validation(socket, :settings, %{
    theme: {:one_of, ["dark", "light"]},
    user: %{
      name: :string,
      role: {:one_of, ["admin", "user"]}
    }
  })

  # Union type validation
  SocketValidator.type_validation(socket, :id, {:union, [:string, :integer]})

  # Custom validation
  SocketValidator.type_validation(socket, :email, {:custom, &is_valid_email?/1})
  ```
  """
  @spec type_validation(Phoenix.LiveView.Socket.t(), atom(), any()) ::
          {:ok, Phoenix.LiveView.Socket.t()} | {:error, String.t(), Phoenix.LiveView.Socket.t()}
  def type_validation(socket, key, type_spec) do
    case Map.fetch(socket.assigns, key) do
      {:ok, value} ->
        case validate_type(value, type_spec) do
          {:ok, _} ->
            {:ok, socket}

          {:error, message} ->
            # Generate error message
            error_message = "Invalid type for #{key}: #{message}"

            # Send telemetry event for type validation failure
            :telemetry.execute(
              [:hydepwns, :socket_validator, :validation, :type_error],
              %{count: 1},
              %{
                key: key,
                type_spec: type_spec,
                error_message: message,
                value: value,
                view_module: Map.get(socket.assigns, :view, "unknown"),
                validation_type: :type_validation
              }
            )

            # Broadcast to pub/sub for debug panel (only in dev)
            if Mix.env() == :dev do
              context_message = context_aware_error(error_message, key, socket)

              error_data = %{
                key: key,
                type: "type_error",
                message: context_message,
                details: %{
                  actual_value: inspect(value),
                  expected_type: inspect(type_spec),
                  view_module: Map.get(socket.assigns, :view, "unknown")
                }
              }

              broadcast_validation_error(
                Map.get(socket.assigns, :view, "unknown"),
                "type_error",
                context_message,
                error_data
              )
            end

            {:error, error_message, socket}
        end

      :error ->
        error_message = "Assign #{key} not found in socket"

        # Send telemetry event for missing key
        :telemetry.execute(
          [:hydepwns, :socket_validator, :validation, :missing_key],
          %{count: 1},
          %{
            key: key,
            view_module: Map.get(socket.assigns, :view, "unknown"),
            validation_type: :type_validation
          }
        )

        # Broadcast to pub/sub for debug panel (only in dev)
        if Mix.env() == :dev do
          error_data = %{
            key: key,
            type: "missing_key",
            message: error_message,
            details: %{
              view_module: Map.get(socket.assigns, :view, "unknown")
            }
          }

          broadcast_validation_error(
            Map.get(socket.assigns, :view, "unknown"),
            "missing_key",
            error_message,
            error_data
          )
        end

        {:error, error_message, socket}
    end
  end

  @doc """
  Creates a context-aware error message with suggested fixes.
  """
  def context_aware_error(message, key, socket) do
    # Get the current value of the assign
    value = Map.get(socket.assigns, key)

    # Get validation history for this assign if available
    validation_history = get_validation_history(socket, key)

    # Basic context info
    value_type = type_of(value)
    view_module = Map.get(socket.assigns, :view, "unknown")

    # Build detailed context info
    value_info = """
    Error in view: #{inspect(view_module)}
    Key: #{key}
    Current value: #{inspect(value)} (#{value_type})
    """

    # Add validation history to context if available
    value_info = add_validation_history_to_context(value_info, validation_history)

    # Get expected type from error message
    expected_type = extract_expected_type(message)

    # Add suggestion based on the error type and context
    suggestion =
      cond do
        # String conversion suggestions
        String.contains?(message, "expected string") && is_integer(value) ->
          """
          Convert the integer to a string:

          ```elixir
          # Using Integer.to_string/1
          #{key} = Integer.to_string(#{inspect(value)})  # "#{Integer.to_string(value)}"

          # Using to_string/1
          #{key} = to_string(#{inspect(value)})  # "#{to_string(value)}"

          # In assign:
          assign(socket, :#{key}, Integer.to_string(#{inspect(value)}))
          ```
          """

        String.contains?(message, "expected string") && is_atom(value) ->
          """
          Convert the atom to a string:

          ```elixir
          # Using Atom.to_string/1
          #{key} = Atom.to_string(#{inspect(value)})  # "#{Atom.to_string(value)}"

          # Using to_string/1
          #{key} = to_string(#{inspect(value)})  # "#{to_string(value)}"

          # In assign:
          assign(socket, :#{key}, Atom.to_string(#{inspect(value)}))
          ```
          """

        # Integer conversion suggestions
        String.contains?(message, "expected integer") && is_binary(value) ->
          case Integer.parse(value) do
            {int, ""} ->
              """
              The string appears to be a valid integer.

              ```elixir
              # Using String.to_integer/1
              #{key} = String.to_integer(#{inspect(value)})  # #{int}

              # In assign:
              assign(socket, :#{key}, String.to_integer(#{inspect(value)}))
              ```
              """

            {int, rest} ->
              """
              The string starts with an integer but has extra characters.

              ```elixir
              # For the integer part only:
              #{key} = String.to_integer(#{inspect(String.replace(value, rest, ""))})  # #{int}

              # Or using pattern matching:
              {#{key}, _rest} = Integer.parse(#{inspect(value)})  # #{int}

              # In assign with pattern matching:
              {parsed_value, _} = Integer.parse(#{inspect(value)})
              assign(socket, :#{key}, parsed_value)
              ```
              """

            :error ->
              """
              The string doesn't represent a valid integer.

              Common issues:
              - Contains non-numeric characters: "#{value}"
              - Empty string: #{value == ""}
              - Using the wrong variable or nil

              Try:
              - Ensure the value is a numeric string
              - Use a default value: `String.to_integer(#{inspect(value)}, 0)`
              - Add validation before conversion: `if is_binary(value) and String.match?(value, ~r/^[0-9]+$/), do: String.to_integer(value), else: 0`
              """
          end

        # Boolean conversion suggestions
        String.contains?(message, "expected boolean") && (value == "true" || value == "false") ->
          """
          Convert the string to a boolean:

          ```elixir
          # Direct comparison
          #{key} = #{inspect(value)} == "true"  # #{value == "true"}

          # In assign:
          assign(socket, :#{key}, #{inspect(value)} == "true")
          ```
          """

        # Map validation failures
        String.contains?(message, "schema validation failed") ->
          # Extract specific schema validation errors
          schema_errors = extract_schema_errors(message)
          schema_error_suggestions = generate_schema_error_suggestions(schema_errors, key, value)

          """
          Schema validation failed for assign ':#{key}'.

          #{schema_error_suggestions}

          Verify the map structure matches the expected schema.
          """

        # List validation failures
        String.contains?(message, "list validation failed") ->
          """
          List validation failed for assign ':#{key}'.

          The list should contain only elements of the expected type.

          Try:
          - Filter invalid elements: `Enum.filter(#{key}, &is_expected_type/1)`
          - Map elements to correct type: `Enum.map(#{key}, &convert_to_expected_type/1)`
          - Use a default empty list if current value isn't valid: `value = is_list(#{key}) && #{key} || []`
          """

        # One of validation failures
        String.contains?(message, "expected one of") && expected_type ->
          expected_values = extract_enum_values(expected_type)

          """
          Value must be one of: #{inspect(expected_values)}

          Current value: #{inspect(value)}

          Try:
          - Ensure value is from the allowed list
          - Use a default value: `value = Enum.member?(#{inspect(expected_values)}, #{inspect(value)}) && #{inspect(value)} || #{inspect(case expected_values do
            [h | _] -> h
            _ -> nil
          end)}`
          - Convert similar values: `String.to_atom(#{inspect(value)})` or `Atom.to_string(#{inspect(value)})`
          """

        # Union type validation failures
        String.contains?(message, "matched none of the union types") && expected_type ->
          union_types = extract_union_types(expected_type)

          """
          Value must match one of the types: #{inspect(union_types)}

          Current value: #{inspect(value)} (#{type_of(value)})

          Try:
          - Convert to a compatible type
          - Use a default value of the correct type
          - Check the data source for this value
          """

        # Custom validation failures
        String.contains?(message, "failed custom validation") ->
          """
          Value failed the custom validation function.

          Try:
          - Check the validation function requirements
          - Update the value to match validation criteria
          - Preprocess the value before validation
          """

        # Fallback for other errors
        true ->
          """
          Try to ensure the value matches the expected type.

          Expected: #{expected_type || "unknown"}
          Actual: #{inspect(value)} (#{type_of(value)})
          """
      end

    # Add type spec suggestion if we can determine the expected type
    type_spec_suggestion =
      if expected_type do
        """

        Specify the correct type in your type_specs/0 function:

        ```elixir
        def type_specs do
          %{
            # ... other specs ...
            #{key}: #{expected_type},
            # ... other specs ...
          }
        end
        ```
        """
      else
        ""
      end

    # Format the error message
    """
    #{message}

    #{value_info}

    ## Suggested Fix

    #{suggestion}
    #{type_spec_suggestion}
    """
  end

  # Helper to extract expected type from error message
  defp extract_expected_type(message) do
    cond do
      String.contains?(message, "expected string") -> ":string"
      String.contains?(message, "expected integer") -> ":integer"
      String.contains?(message, "expected boolean") -> ":boolean"
      String.contains?(message, "expected map") -> ":map"
      String.contains?(message, "expected list") -> ":list"
      String.contains?(message, "expected atom") -> ":atom"
      String.contains?(message, "expected function") -> ":function"
      String.contains?(message, "expected float") -> ":float"
      String.contains?(message, "expected number") -> ":number"
      String.contains?(message, "expected one of") -> extract_enum_type(message)
      String.contains?(message, "matched none of the union types") -> extract_union_type(message)
      true -> nil
    end
  end

  # Extract enum type from error message
  defp extract_enum_type(message) do
    case Regex.run(~r/expected one of: (.+)/, message) do
      [_, values_str] ->
        if is_binary(values_str) do
          trimmed = String.trim(values_str)

          if trimmed != "" do
            "{:one_of, [" <> trimmed <> "]}"
          else
            nil
          end
        else
          nil
        end

      _ ->
        nil
    end
  end

  # Extract enum values from the type spec string
  defp extract_enum_values(type_spec) do
    case Regex.run(~r/{:one_of, \[(.*)\]}/, type_spec) do
      [_, values_str] ->
        if is_binary(values_str) do
          trimmed = String.trim(values_str)

          if trimmed != "" do
            trimmed
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.reject(&(&1 == ""))
          else
            []
          end
        else
          []
        end

      _ ->
        []
    end
  end

  # Extract union type from error message
  defp extract_union_type(message) do
    case Regex.run(~r/matched none of the union types: (.+)/, message) do
      [_, types_str] ->
        "{:union, [#{types_str}]}"

      _ ->
        nil
    end
  end

  # Extract union types from the type spec string
  defp extract_union_types(type_spec) do
    case Regex.run(~r/{:union, \[(.+)\]}/, type_spec) do
      [_, types_str] ->
        types_str |> String.split(",") |> Enum.map(&String.trim/1)

      _ ->
        []
    end
  end

  # Extract schema validation errors from the error message
  defp extract_schema_errors(message) do
    case Regex.run(~r/schema validation failed: (.+)/, message) do
      [_, errors_str] ->
        errors_str |> String.split(", ") |> Enum.map(&parse_schema_error/1)

      _ ->
        []
    end
  end

  # Parse individual schema error
  defp parse_schema_error(error_str) do
    case Regex.run(~r/(.+): (.+)/, error_str) do
      [_, path, error] ->
        %{path: path, error: error}

      _ ->
        %{path: "unknown", error: error_str}
    end
  end

  # Generate suggestions for schema errors
  defp generate_schema_error_suggestions(schema_errors, _key, value) do
    Enum.map(schema_errors, fn %{path: path, error: error} ->
      field_path = String.split(path, ".")
      suggested_fix = suggest_fix_for_schema_error(field_path, error, value)

      """
      - #{path}: #{error}
        #{suggested_fix}
      """
    end)
    |> Enum.join("\n")
  end

  # Suggest fixes for schema validation errors
  defp suggest_fix_for_schema_error(field_path, error, value) do
    field_value = get_nested_value(value, field_path)

    cond do
      error =~ "expected string" && field_value != nil ->
        "Try converting to string: `to_string(#{inspect(field_value)})`"

      error =~ "expected integer" && is_binary(field_value) ->
        "Try converting to integer: `String.to_integer(#{inspect(field_value)})`"

      error =~ "expected boolean" && (field_value == "true" || field_value == "false") ->
        "Try converting to boolean: `#{inspect(field_value)} == \"true\"`"

      error =~ "expected one of" ->
        allowed_values = Regex.run(~r/expected one of: (.+)/, error)

        case allowed_values do
          [_, values_str] ->
            "Value must be one of: #{values_str}"

          _ ->
            "Ensure value is one of the allowed values"
        end

      field_value == nil ->
        "Field is missing. Ensure it exists in the map."

      true ->
        "Ensure the value matches the expected type."
    end
  end

  # Get nested value from a map using a list of keys
  defp get_nested_value(map, []), do: map
  defp get_nested_value(nil, _), do: nil

  defp get_nested_value(map, [key | rest]) when is_map(map) do
    key = if is_binary(key), do: String.to_existing_atom(key), else: key
    get_nested_value(Map.get(map, key), rest)
  rescue
    _ -> nil
  end

  defp get_nested_value(_, _), do: nil

  # Determine the type of a value
  defp type_of(value) when is_binary(value), do: "string"
  defp type_of(value) when is_integer(value), do: "integer"
  defp type_of(value) when is_boolean(value), do: "boolean"
  defp type_of(value) when is_float(value), do: "float"
  defp type_of(value) when is_map(value), do: "map"
  defp type_of(value) when is_list(value), do: "list"
  defp type_of(value) when is_atom(value), do: "atom"
  defp type_of(value) when is_function(value), do: "function"
  defp type_of(value) when is_nil(value), do: "nil"
  defp type_of(_), do: "unknown"

  # Function to broadcast validation errors to the debug panel in development
  defp broadcast_validation_error(view_module, type, message, details) do
    # Check if we're in development mode
    if Mix.env() == :dev do
      # Create a unique ID for this error
      error_id = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

      # Add timestamp
      error_with_timestamp =
        details
        |> Map.put(:id, error_id)
        |> Map.put(:timestamp, DateTime.utc_now())
        |> Map.put(:message, message)
        |> Map.put(:type, type)
        |> Map.put(:view_module, view_module)

      # Broadcast to the debug panel
      Phoenix.PubSub.broadcast(
        HydepwnsLiveview.PubSub,
        "socket_validation",
        {:socket_validation_error, error_with_timestamp}
      )
    end
  end

  @doc """
  Records detailed telemetry metrics for validation events.
  """
  @spec record_validation_telemetry(atom(), map(), map()) :: :ok
  def record_validation_telemetry(event_name, metric_value, metadata) do
    # Build the full event name
    event = [:hydepwns, :socket_validator, :validation, event_name]

    # Add timestamp if not provided
    metadata = Map.put_new(metadata, :timestamp, DateTime.utc_now())

    # Add environment information
    metadata = Map.put_new(metadata, :environment, Mix.env())

    # Add validation_type if not provided
    metadata = Map.put_new(metadata, :validation_type, :general)

    # Execute the telemetry event
    :telemetry.execute(event, metric_value, metadata)
  end

  @doc """
  Creates a histogram of validation errors over time.
  """
  @spec validation_error_histogram(integer()) :: map()
  def validation_error_histogram(_time_window \\ 3600) do
    # This is a placeholder implementation
    # In a real implementation, this would query telemetry data
    # from a storage backend where the events are aggregated

    # For demonstration, return a mock result
    %{
      type_error: 0,
      missing_key: 0,
      missing_assigns: 0,
      schema_error: 0,
      custom_validation_error: 0
    }
  end

  @doc """
  Retrieves validation history for a specific socket assign key.
  Used to track previous values of assigns for better error context.
  """
  def get_validation_history(_socket, _key) do
    # Get validation history from socket storage or ETS
    # For now returning a simple empty history structure
    %{
      recent_values: [],
      error_count: 0,
      last_valid_value: nil
    }
  end

  defp add_validation_history_to_context(value_info, validation_history) do
    # Add validation history to context if available
    if validation_history && !Enum.empty?(validation_history[:recent_values]) do
      context_with_header = value_info <> "\nRecent values:\n"

      # Use Enum.reduce instead of Enum.each to build the string properly
      Enum.with_index(validation_history[:recent_values], 1)
      |> Enum.reverse()
      |> Enum.take(-3)
      |> Enum.reduce(context_with_header, fn {historical_value, idx}, acc ->
        "#{acc}\n  #{idx}: #{inspect(historical_value)} (#{type_of(historical_value)})"
      end)
    else
      value_info
    end
  end
end
