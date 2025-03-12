defmodule HydepwnsLiveview.Resources.EctoUserResource do
  @moduledoc """
  A resource that uses the EctoAdapter with the User schema.

  This demonstrates how to use the adapter system to create resources
  that are backed by Ecto schemas without having to manually define
  all the attributes.
  """

  use HydepwnsLiveview.Utils.LiveViewResource

  # Use the EctoAdapter with the User schema
  adapter(HydepwnsLiveview.Utils.EctoAdapter, schema: HydepwnsLiveview.Schemas.User)

  # We don't need to define attributes, relationships, or validations here
  # since they are extracted from the User schema by the EctoAdapter.
  # However, we can override or add to them if needed:

  # Define validations directly in the function
  def validations do
    [
      %{
        name: :ensure_valid_email_domain,
        validation_fn: fn resource ->
          if resource.email && String.contains?(resource.email, "@example.com") do
            :ok
          else
            {:error, "Email must be from the example.com domain"}
          end
        end
      }
    ]
  end
end
