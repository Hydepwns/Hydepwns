#!/usr/bin/env elixir

# This script demonstrates how to use the Resource Transformation Pipeline
# in a real-world scenario.

# Ensure the application is loaded
Application.ensure_all_started(:hydepwns_liveview)

alias HydepwnsLiveview.Transformations.NormalizeEmail
alias HydepwnsLiveview.Transformations.GenerateUsername
alias HydepwnsLiveview.TransformationRegistry

# Create a mock database of existing usernames
existing_usernames = MapSet.new(["johndoe", "janedoe", "bobsmith", "alicejones"])

# Create a function to check if a username exists
username_exists? = fn username ->
  MapSet.member?(existing_usernames, username)
end

# Create a transformation registry with our transformations
IO.puts("Creating transformation registry...")
registry = TransformationRegistry.new()
|> TransformationRegistry.register(NormalizeEmail)
|> TransformationRegistry.register(GenerateUsername)

# Print registered transformations
IO.puts("\nRegistered transformations:")
registry.transformations
|> Enum.each(fn {_id, module} ->
  info = module.info()
  IO.puts("- #{info.name}: #{info.description}")
end)

# Create some example resources
resources = [
  %{
    name: "John Doe",
    email: "John.Doe@Example.COM"
  },
  %{
    name: "Jane Doe",
    email: "JANE@example.com"
  },
  %{
    name: "Bob Smith",
    email: "bob.smith@example.com"
  },
  %{
    name: "Alice Jones",
    email: "Alice.Jones@EXAMPLE.com"
  }
]

# Process each resource
IO.puts("\nProcessing resources:")
Enum.each(resources, fn resource ->
  IO.puts("\nOriginal resource:")
  IO.inspect(resource)
  
  # Create context with username conflict checker
  context = %{
    username_exists?: username_exists?
  }
  
  # Apply all applicable transformations
  case TransformationRegistry.apply_all(registry, resource, context) do
    {:ok, transformed} ->
      IO.puts("Transformed resource:")
      IO.inspect(transformed)
      
      # Show which transformations were applied
      if Map.get(resource, :email) != Map.get(transformed, :email) do
        IO.puts("- Email was normalized")
      end
      
      if Map.get(transformed, :username) do
        IO.puts("- Username was generated: #{transformed.username}")
        
        # Add the new username to our existing usernames set
        # (to simulate database persistence)
        existing_usernames = MapSet.put(existing_usernames, transformed.username)
      end
      
    {:error, reason} ->
      IO.puts("Error transforming resource: #{inspect(reason)}")
  end
end)

IO.puts("\nTransformation demo completed!") 