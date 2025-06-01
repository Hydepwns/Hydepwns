defmodule HydepwnsLiveview.Utils.ContextValidation do
  defp prepare_related_context(context, parent, relationship, _child) do
    parent_id = parent.id
    _child_id = _child.id
    relationship_id = relationship.id

    context
    |> Map.put(:parent_id, parent_id)
    |> Map.put(:child_id, _child_id)
    |> Map.put(:relationship_id, relationship_id)
  end
end
