defmodule HydepwnsLiveview.Transformations.TransformationExamplesTest do
  use ExUnit.Case, async: true

  alias HydepwnsLiveview.Transformations.NormalizeEmail
  alias HydepwnsLiveview.Transformations.GenerateUsername
  alias HydepwnsLiveview.TransformationRegistry

  describe "individual transformations" do
    test "NormalizeEmail transforms email to lowercase" do
      resource = %{email: "User@Example.COM"}

      assert {:ok, transformed} = NormalizeEmail.transform(resource, %{})
      assert transformed.email == "user@example.com"
    end

    test "NormalizeEmail doesn't modify resources without email" do
      resource = %{name: "John Doe"}

      assert {:ok, ^resource} = NormalizeEmail.transform(resource, %{})
    end

    test "GenerateUsername creates username from name" do
      resource = %{name: "John Doe"}

      assert {:ok, transformed} = GenerateUsername.transform(resource, %{})
      assert transformed.username == "johndoe"
    end

    test "GenerateUsername handles special characters" do
      resource = %{name: "Jane O'Connor-Smith"}

      assert {:ok, transformed} = GenerateUsername.transform(resource, %{})
      assert transformed.username == "janeoconnorsmith"
    end

    test "GenerateUsername ensures minimum length" do
      resource = %{name: "Jo"}

      assert {:ok, transformed} = GenerateUsername.transform(resource, %{})
      assert transformed.username == "jo0"
    end

    test "GenerateUsername handles username conflicts" do
      resource = %{name: "John Doe"}

      # Create a context with a function that says "johndoe" already exists
      # but "johndoe1" doesn't
      context = %{
        username_exists?: fn username ->
          username == "johndoe"
        end
      }

      assert {:ok, transformed} = GenerateUsername.transform(resource, context)
      assert transformed.username == "johndoe1"
    end
  end

  describe "transformation pipeline" do
    setup do
      # Create a registry with our transformations
      registry =
        TransformationRegistry.new()
        |> TransformationRegistry.register(NormalizeEmail)
        |> TransformationRegistry.register(GenerateUsername)

      {:ok, registry: registry}
    end

    test "applies multiple transformations in sequence", %{registry: registry} do
      # Create a resource that needs both email normalization and username generation
      resource = %{
        name: "John Doe",
        email: "John.Doe@Example.COM"
      }

      # Create a context with a username conflict checker
      context = %{
        username_exists?: fn username ->
          username == "johndoe"
        end
      }

      # Apply all applicable transformations
      {:ok, transformed} = TransformationRegistry.apply_all(registry, resource, context)

      # Verify both transformations were applied
      assert transformed.email == "john.doe@example.com"
      assert transformed.username == "johndoe1"
    end

    test "respects transformation dependencies", %{registry: registry} do
      # This test demonstrates that transformations with dependencies
      # are applied in the correct order

      # Create a resource
      resource = %{
        name: "John Doe",
        email: "John.Doe@Example.COM"
      }

      # Get the execution plan
      plan = TransformationRegistry.execution_plan(registry, resource, %{})

      # Verify NormalizeEmail comes before GenerateUsername
      # (since GenerateUsername depends on NormalizeEmail)
      normalize_email_index = Enum.find_index(plan, fn module -> module == NormalizeEmail end)
      generate_username_index = Enum.find_index(plan, fn module -> module == GenerateUsername end)

      assert normalize_email_index < generate_username_index
    end
  end
end
