defmodule HydepwnsLiveview.RepoHelper do
  @moduledoc """
  Helper module for accessing the configured repo (real or mock).

  This module provides a centralized way to access the database repository,
  allowing for easy switching between real and mock repositories for testing.
  """

  @doc """
  Returns the configured repo module (real Repo or mock).
  """
  def repo do
    Application.get_env(:hydepwns_liveview, :repo, HydepwnsLiveview.Repo)
  end

  @doc """
  Convenience function for repo().get/3

  ## Parameters

  - `schema` - The Ecto schema module
  - `id` - The primary key value
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `nil` - Record not found
  - `struct` - The found record

  ## Examples

  ```elixir
  # Get a user by ID
  user = RepoHelper.get(User, 1)

  # Get with timeout
  user = RepoHelper.get(User, 1, timeout: 5000)
  ```
  """
  def get(schema, id, opts \\ []) do
    repo().get(schema, id, opts)
  end

  @doc """
  Convenience function for repo().get!/2

  ## Parameters

  - `schema` - The Ecto schema module
  - `id` - The primary key value
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `struct` - The found record

  ## Raises

  - `Ecto.QueryError` - If the record is not found

  ## Examples

  ```elixir
  # Get a user by ID (raises if not found)
  user = RepoHelper.get!(User, 1)
  ```
  """
  def get!(schema, id, opts \\ []) do
    repo().get!(schema, id, opts)
  end

  @doc """
  Convenience function for repo().get_by/2

  ## Parameters

  - `schema` - The Ecto schema module
  - `clauses` - The where clauses
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `nil` - Record not found
  - `struct` - The found record

  ## Examples

  ```elixir
  # Get a user by email
  user = RepoHelper.get_by(User, email: "test@example.com")

  # Get with timeout
  user = RepoHelper.get_by(User, email: "test@example.com", timeout: 5000)
  ```
  """
  def get_by(schema, clauses, opts \\ []) do
    repo().get_by(schema, clauses, opts)
  end

  @doc """
  Convenience function for repo().insert/2

  ## Parameters

  - `struct` - The struct to insert
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `{:ok, struct}` - Insert successful
  - `{:error, changeset}` - Insert failed

  ## Examples

  ```elixir
  # Insert a new user
  {:ok, user} = RepoHelper.insert(%User{name: "John", email: "john@example.com"})
  ```
  """
  def insert(struct, opts \\ []) do
    repo().insert(struct, opts)
  end

  @doc """
  Convenience function for repo().update/2

  ## Parameters

  - `struct` - The struct to update
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `{:ok, struct}` - Update successful
  - `{:error, changeset}` - Update failed

  ## Examples

  ```elixir
  # Update a user
  {:ok, updated_user} = RepoHelper.update(%{user | name: "Jane"})
  ```
  """
  def update(struct, opts \\ []) do
    repo().update(struct, opts)
  end

  @doc """
  Convenience function for repo().delete/2

  ## Parameters

  - `struct` - The struct to delete
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `{:ok, struct}` - Delete successful
  - `{:error, changeset}` - Delete failed

  ## Examples

  ```elixir
  # Delete a user
  {:ok, deleted_user} = RepoHelper.delete(user)
  ```
  """
  def delete(struct, opts \\ []) do
    repo().delete(struct, opts)
  end

  @doc """
  Convenience function for repo().all/2

  ## Parameters

  - `queryable` - The queryable (schema or query)
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `[struct]` - List of records

  ## Examples

  ```elixir
  # Get all users
  users = RepoHelper.all(User)

  # Get with timeout
  users = RepoHelper.all(User, timeout: 5000)
  ```
  """
  def all(queryable, opts \\ []) do
    repo().all(queryable, opts)
  end

  @doc """
  Convenience function for repo().one/2

  ## Parameters

  - `queryable` - The queryable (schema or query)
  - `opts` - Optional parameters (default: [])

  ## Returns

  - `nil` - No record found
  - `struct` - The found record

  ## Examples

  ```elixir
  # Get one user
  user = RepoHelper.one(User)

  # Get with timeout
  user = RepoHelper.one(User, timeout: 5000)
  ```
  """
  def one(queryable, opts \\ []) do
    repo().one(queryable, opts)
  end
end 