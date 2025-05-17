defmodule HydepwnsLiveview.ResourceSystem do
  @moduledoc false

  def create_resource(attrs) do
    # Simulate DB insert by returning {:ok, resource}
    resource = Map.merge(%{
      id: System.unique_integer([:positive]),
      name: Map.get(attrs, :name, "Test Resource"),
      description: Map.get(attrs, :description, "A resource for testing"),
      type: Map.get(attrs, :type, "default"),
      data: Map.get(attrs, :data, %{})
    }, attrs)

    {:ok, resource}
  end
end 