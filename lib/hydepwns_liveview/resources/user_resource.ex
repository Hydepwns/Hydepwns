defmodule HydepwnsLiveview.Resources.UserResource do
  @moduledoc """
  Provides a high-level interface for user resource operations.
  """

  alias HydepwnsLiveview.Resources.Examples.UserResource, as: ExampleUserResource

  @doc """
  Executes a command on a user resource.

  ## Parameters
  * `resource` - The user resource
  * `command` - The command to execute
  * `params` - Command parameters

  ## Returns
  * `{:ok, events, updated_resource}` - Command executed successfully
  * `{:error, reason}` - Command failed
  """
  defdelegate execute_command(resource, command, params), to: ExampleUserResource

  @doc """
  Updates a user resource.

  ## Parameters
  * `resource` - The user resource to update
  * `updates` - Map of updates to apply
  * `metadata` - Additional metadata about the update

  ## Returns
  * `{:ok, events, updated_resource}` - Update was successful
  * `{:error, reason}` - Update failed
  """
  defdelegate update(resource, updates, metadata \\ %{}), to: ExampleUserResource
end 