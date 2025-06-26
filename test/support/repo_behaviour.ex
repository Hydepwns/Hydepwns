defmodule HydepwnsLiveview.TestRepoBehaviour do
  @moduledoc """
  Behaviour for Repo functions that can be mocked in tests.
  """

  @callback get(module, any, Keyword.t()) :: any
  @callback get!(module, any, Keyword.t()) :: any
  @callback get_by(module, Keyword.t(), Keyword.t()) :: any
  @callback get_by(module, Keyword.t()) :: any
  @callback insert(Ecto.Changeset.t()) :: {:ok, any} | {:error, Ecto.Changeset.t()}
  @callback update(Ecto.Changeset.t()) :: {:ok, any} | {:error, Ecto.Changeset.t()}
  @callback delete(any) :: {:ok, any} | {:error, Ecto.Changeset.t()}
  @callback delete_all(module) :: {integer, nil}
end 