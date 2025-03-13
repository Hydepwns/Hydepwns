# Hydepwns Examples

This directory contains example scripts and demos that showcase various features of the Hydepwns platform.

## Transformation Demo

The `transformation_demo.exs` script demonstrates how to use the Resource Transformation Pipeline in a real-world scenario. It shows:

1. How to create and register transformations
2. How to apply transformations to resources
3. How to handle transformation dependencies
4. How to use context to share data between transformations
5. How to handle conflicts in transformations (e.g., username conflicts)

### Running the Demo

To run the transformation demo:

```bash
./examples/transformation_demo.exs
```

Or:

```bash
mix run examples/transformation_demo.exs
```

### Example Transformations

The demo uses two example transformations:

1. **NormalizeEmail**: A simple transformation that normalizes email addresses to lowercase
2. **GenerateUsername**: A more complex transformation that generates usernames from user names, with conflict resolution

These transformations demonstrate different aspects of the transformation system:

- Basic field normalization
- Conditional application based on field presence
- Dependency management between transformations
- Context-aware transformations (using external data)
- Conflict resolution

### Expected Output

The demo will process several example resources, applying transformations as appropriate. For each resource, it will show:

- The original resource
- The transformed resource
- Which transformations were applied
- Any generated usernames

### Further Reading

For more information about the Resource Transformation Pipeline, see:

- [Resource Transformation Pipeline Documentation](../docs/PRD/resource_transformation_pipeline.md)
- [NormalizeEmail Implementation](../lib/hydepwns_liveview/transformations/normalize_email.ex)
- [GenerateUsername Implementation](../lib/hydepwns_liveview/transformations/generate_username.ex)
- [Transformation Tests](../test/hydepwns_liveview/transformations/transformation_examples_test.exs) 