defmodule HydepwnsLiveview.Resources.FolderResource do
  @moduledoc """
  Defines the Folder resource for LiveViews and tests.
  """

  defstruct [
    :id,
    :name,
    :type,
    :content,
    :__resource_module__
  ]

  @doc """
  Returns the initial state for a folder resource as a struct.
  """
  def initial_state do
    %__MODULE__{
      id: nil,
      name: nil,
      type: "folder",
      content: nil,
      __resource_module__: __MODULE__
    }
  end

  @doc """
  Applies an event to the folder resource state, always returning a struct.
  """
  def apply_event(event, %__MODULE__{} = state) do
    case event.type do
      "folder.created" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))
      "folder.updated" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))
      "folder.deleted" ->
        %{state | content: nil}
      _ ->
        struct(state, Map.merge(Map.from_struct(state), event.data || %{}))
    end
  end

  @doc """
  Validates a folder resource map or struct. Returns {:ok, struct} or {:error, errors}.
  """
  def validate(attrs) when is_map(attrs) do
    errors = []
    errors = if is_nil(attrs.name) or attrs.name == "", do: [{:name, "Name can't be blank"} | errors], else: errors
    errors = if attrs.name && String.length(attrs.name) < 3, do: [{:name, "Name is too short"} | errors], else: errors
    errors = if is_nil(attrs.type) or attrs.type == "", do: [{:type, "Type can't be blank"} | errors], else: errors
    errors = if attrs.type && attrs.type not in ["document", "folder"], do: [{:type, "Invalid resource type"} | errors], else: errors
    if errors == [], do: {:ok, struct(__MODULE__, attrs)}, else: {:error, errors}
  end
end 