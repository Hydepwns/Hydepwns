defmodule HydepwnsLiveview.Utils.ContextValidation do
  defp prepare_related_context(context, parent, _relationship, child) do
    child_id = child.id
    context
    |> Map.put(:parent, parent)
    |> Map.put(:child_id, child_id)
  end
end
