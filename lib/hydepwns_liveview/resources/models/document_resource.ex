defmodule HydepwnsLiveview.Resources.DocumentResource do
  @moduledoc """
  Defines the Document resource for LiveViews and tests.
  """

  defstruct [
    :id,
    :name,
    :type,
    :content,
    :description,
    :parent_id,
    :__resource_module__
  ]

  @doc """
  Returns the initial state for a document resource as a struct.
  """
  def initial_state do
    %__MODULE__{
      id: nil,
      name: nil,
      type: "document",
      content: nil,
      description: nil,
      parent_id: nil,
      __resource_module__: __MODULE__
    }
  end

  @doc """
  Applies an event to the document resource state, always returning a struct.
  """
  def apply_event(event, %__MODULE__{} = state) do
    case event.type do
      "document.created" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))

      "document.updated" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))

      "document.deleted" ->
        %{state | content: nil}

      _ ->
        struct(state, Map.merge(Map.from_struct(state), event.data || %{}))
    end
  end

  @doc """
  Validates a document resource map or struct. Returns {:ok, struct} or {:error, errors}.

  # NOTE: Do not use this directly in LiveView forms or controllers. Use `changeset/1` for form validation.
  """
  def validate(attrs) when is_map(attrs) do
    errors = []

    errors =
      if is_nil(attrs["name"]) or attrs["name"] == "",
        do: [{:name, "Name can't be blank"} | errors],
        else: errors

    errors =
      if attrs["name"] && String.length(attrs["name"]) < 3,
        do: [{:name, "Name is too short"} | errors],
        else: errors

    errors =
      if is_nil(attrs["type"]) or attrs["type"] == "",
        do: [{:type, "Type can't be blank"} | errors],
        else: errors

    errors =
      if attrs["type"] && attrs["type"] not in ["document", "folder"],
        do: [{:type, "Invalid resource type"} | errors],
        else: errors

    errors =
      if is_nil(attrs["content"]) or attrs["content"] == "",
        do: [{:content, "Content can't be blank"} | errors],
        else: errors

    errors =
      if attrs["parent_id"] && !is_binary(attrs["parent_id"]),
        do: [{:parent_id, "Parent ID must be a string or nil"} | errors],
        else: errors

    if errors == [], do: {:ok, struct(__MODULE__, attrs)}, else: {:error, errors}
  end

  # Returns an Ecto.Changeset for use in LiveView forms
  def changeset(attrs) when is_map(attrs) do
    attrs = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}

    types = %{
      id: :string,
      name: :string,
      type: :string,
      content: :string,
      description: :string,
      parent_id: :string
    }

    case validate(attrs) do
      {:ok, _struct} ->
        {%{}, types}
        |> Ecto.Changeset.cast(attrs, Map.keys(types))

      {:error, errors} ->
        changeset = {%{}, types} |> Ecto.Changeset.cast(attrs, Map.keys(types))

        Enum.reduce(errors, changeset, fn {field, msg}, cs ->
          Ecto.Changeset.add_error(cs, field, msg)
        end)
    end
  end

  def changeset(_), do: Ecto.Changeset.change(%{})
end
