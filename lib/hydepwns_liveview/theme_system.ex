defmodule HydepwnsLiveview.ThemeSystem do
  @moduledoc false

  # Mock theme struct that matches the expected interface
  defmodule MockTheme do
    defstruct [
      :id,
      :name,
      :mode,
      :primary_color,
      :secondary_color,
      :background_color,
      :text_color,
      :is_default,
      :settings,
      :colors,
      :inserted_at,
      :updated_at
    ]

    def mode(%__MODULE__{mode: mode}), do: mode
  end

  @ets_table :theme_system_themes

  defp ensure_ets_table do
    case :ets.info(@ets_table) do
      :undefined ->
        :ets.new(@ets_table, [:named_table, :public, :set])
        :ets.insert(@ets_table, {:next_id, 2})
        default_theme = %MockTheme{
          id: 1,
          name: "Default Theme",
          mode: "light",
          primary_color: "#3B82F6",
          secondary_color: "#10B981",
          background_color: "#FFFFFF",
          text_color: "#1F2937",
          is_default: true,
          settings: %{},
          colors: %{},
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
        :ets.insert(@ets_table, {1, default_theme})
      _ ->
        :ok
    end
  end

  defp get_themes do
    ensure_ets_table()
    :ets.tab2list(@ets_table)
    |> Enum.filter(fn {k, _v} -> is_integer(k) end)
    |> Enum.map(fn {_k, v} -> v end)
  end

  defp get_next_id do
    ensure_ets_table()
    case :ets.lookup(@ets_table, :next_id) do
      [{:next_id, id}] -> id
      _ -> 2
    end
  end

  defp set_next_id(id), do: :ets.insert(@ets_table, {:next_id, id})

  defp set_theme(theme) do
    :ets.insert(@ets_table, {theme.id, theme})
  end

  defp delete_theme_by_id(id) do
    :ets.delete(@ets_table, id)
  end

  # Helper to convert MockTheme to Theme struct for testing
  defp mock_to_theme(%MockTheme{} = mock_theme) do
    %HydepwnsLiveview.ThemeSystem.Models.Theme{
      id: mock_theme.id,
      name: mock_theme.name,
      mode: mock_theme.mode,
      primary_color: mock_theme.primary_color,
      secondary_color: mock_theme.secondary_color,
      background_color: mock_theme.background_color,
      text_color: mock_theme.text_color,
      is_default: mock_theme.is_default,
      settings: mock_theme.settings,
      colors: mock_theme.colors,
      inserted_at: mock_theme.inserted_at,
      updated_at: mock_theme.updated_at
    }
  end

  def ensure_default_theme do
    ensure_ets_table()
    get_themes()
    |> Enum.find(fn theme -> theme.is_default end)
    |> case do
      nil ->
        default_theme = %MockTheme{
          id: 1,
          name: "Default Theme",
          mode: "light",
          primary_color: "#3B82F6",
          secondary_color: "#10B981",
          background_color: "#FFFFFF",
          text_color: "#1F2937",
          is_default: true,
          settings: %{},
          colors: %{},
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
        set_theme(default_theme)
        default_theme
      theme ->
        theme
    end
  end

  def get_theme!(id) do
    ensure_ets_table()
    case :ets.lookup(@ets_table, id) do
      [{^id, theme}] -> mock_to_theme(theme)
      _ -> raise Ecto.NoResultsError, queryable: "themes", message: "Theme not found"
    end
  end

  # For test isolation: clear all themes and reset next_id
  def reset_themes do
    ensure_ets_table()
    :ets.delete_all_objects(@ets_table)
    :ets.insert(@ets_table, {:next_id, 1})
  end

  def get_theme_by_name(name) do
    ensure_ets_table()
    get_themes()
    |> Enum.find(fn theme -> theme.name == name end)
    |> case do
      nil -> nil
      theme -> mock_to_theme(theme)
    end
  end

  def get_default_theme do
    ensure_ets_table()
    get_themes()
    |> Enum.find(fn theme -> theme.is_default end)
    |> case do
      nil -> ensure_default_theme() |> mock_to_theme()
      theme -> mock_to_theme(theme)
    end
  end

  def set_default_theme(theme) do
    ensure_ets_table()
    # Convert Theme to MockTheme if needed
    mock_theme = case theme do
      %HydepwnsLiveview.ThemeSystem.Models.Theme{} ->
        %MockTheme{
          id: theme.id,
          name: theme.name,
          mode: theme.mode,
          primary_color: theme.primary_color,
          secondary_color: theme.secondary_color,
          background_color: theme.background_color,
          text_color: theme.text_color,
          is_default: theme.is_default,
          settings: theme.settings,
          colors: theme.colors,
          inserted_at: theme.inserted_at,
          updated_at: theme.updated_at
        }
      %MockTheme{} -> theme
    end
    
    # First, unset all existing defaults
    get_themes()
    |> Enum.filter(fn t -> t.is_default end)
    |> Enum.each(fn t ->
      updated_theme = %{t | is_default: false, updated_at: DateTime.utc_now()}
      set_theme(updated_theme)
    end)
    
    # Then set the new default
    updated_theme = %{mock_theme | is_default: true, updated_at: DateTime.utc_now()}
    set_theme(updated_theme)
    {:ok, mock_to_theme(updated_theme)}
  end

  def update_theme(theme, params) do
    ensure_ets_table()
    
    # Convert Theme to MockTheme if needed
    mock_theme = case theme do
      %HydepwnsLiveview.ThemeSystem.Models.Theme{} ->
        %MockTheme{
          id: theme.id,
          name: theme.name,
          mode: theme.mode,
          primary_color: theme.primary_color,
          secondary_color: theme.secondary_color,
          background_color: theme.background_color,
          text_color: theme.text_color,
          is_default: theme.is_default,
          settings: theme.settings,
          colors: theme.colors,
          inserted_at: theme.inserted_at,
          updated_at: theme.updated_at
        }
      %MockTheme{} -> theme
    end
    
    # Validate the params
    case validate_theme_params(params) do
      {:ok, validated_params} ->
        updated_theme = Map.merge(mock_theme, validated_params)
        updated_theme = %{updated_theme | updated_at: DateTime.utc_now()}
        set_theme(updated_theme)
        {:ok, mock_to_theme(updated_theme)}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def apply_theme(theme) do
    {:ok, theme}
  end

  def list_themes do
    ensure_ets_table()
    themes = get_themes()
    if themes == [] do
      [ensure_default_theme() |> mock_to_theme()]
    else
      Enum.map(themes, &mock_to_theme/1)
    end
  end

  def create_theme(params) do
    ensure_ets_table()
    
    # Validate the params
    case validate_theme_params(params) do
      {:ok, validated_params} ->
        id = get_next_id()
        theme = %MockTheme{
          id: id,
          name: validated_params[:name] || "Theme #{id}",
          mode: validated_params[:mode] || "light",
          primary_color: validated_params[:primary_color] || "#3B82F6",
          secondary_color: validated_params[:secondary_color] || "#10B981",
          background_color: validated_params[:background_color] || "#FFFFFF",
          text_color: validated_params[:text_color] || "#1F2937",
          is_default: validated_params[:is_default] || false,
          settings: validated_params[:settings] || %{},
          colors: validated_params[:colors] || %{},
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
        set_theme(theme)
        set_next_id(id + 1)
        {:ok, mock_to_theme(theme)}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def change_theme(theme) do
    # Return a mock changeset for the theme
    %Ecto.Changeset{
      data: theme,
      changes: %{},
      errors: [],
      valid?: true,
      action: nil
    }
  end

  def delete_theme(theme) do
    ensure_ets_table()
    # Convert Theme to MockTheme if needed
    mock_theme = case theme do
      %HydepwnsLiveview.ThemeSystem.Models.Theme{} ->
        %MockTheme{
          id: theme.id,
          name: theme.name,
          mode: theme.mode,
          primary_color: theme.primary_color,
          secondary_color: theme.secondary_color,
          background_color: theme.background_color,
          text_color: theme.text_color,
          is_default: theme.is_default,
          settings: theme.settings,
          colors: theme.colors,
          inserted_at: theme.inserted_at,
          updated_at: theme.updated_at
        }
      %MockTheme{} -> theme
    end
    
    delete_theme_by_id(mock_theme.id)
    {:ok, mock_to_theme(mock_theme)}
  end

  def get_current_theme do
    {:ok, ensure_default_theme() |> mock_to_theme()}
  end

  # Private validation function
  defp validate_theme_params(params) do
    # Check required fields
    required_fields = [:name, :mode, :primary_color, :secondary_color, :background_color, :text_color]
    missing_fields = Enum.filter(required_fields, fn field -> 
      value = Map.get(params, field) || Map.get(params, to_string(field))
      is_nil(value) || value == ""
    end)
    
    if missing_fields != [] do
      changeset = %Ecto.Changeset{
        data: nil,
        changes: %{},
        errors: Enum.map(missing_fields, fn field -> {field, {"can't be blank", [validation: :required]}} end),
        valid?: false,
        action: :validate
      }
      {:error, changeset}
    else
      # Validate mode
      mode = Map.get(params, :mode) || Map.get(params, "mode")
      valid_modes = ["light", "dark", "dim", "system", "synthwave"]
      
      if mode && mode not in valid_modes do
        changeset = %Ecto.Changeset{
          data: nil,
          changes: %{},
          errors: [{:mode, {"is invalid", [validation: :inclusion, enum: valid_modes]}}],
          valid?: false,
          action: :validate
        }
        {:error, changeset}
      else
        # Validate color format
        color_fields = [:primary_color, :secondary_color, :background_color, :text_color]
        invalid_colors = Enum.filter(color_fields, fn field ->
          color = Map.get(params, field) || Map.get(params, to_string(field))
          color && !Regex.match?(~r/^#[0-9A-Fa-f]{6}$/, color)
        end)
        
        if invalid_colors != [] do
          changeset = %Ecto.Changeset{
            data: nil,
            changes: %{},
            errors: Enum.map(invalid_colors, fn field -> {field, {"must be a valid hex color", [validation: :format]}} end),
            valid?: false,
            action: :validate
          }
          {:error, changeset}
        else
          # Convert string keys to atoms for consistency
          validated_params = for {k, v} <- params, into: %{} do
            key = if is_binary(k), do: String.to_atom(k), else: k
            {key, v}
          end
          {:ok, validated_params}
        end
      end
    end
  end
end
