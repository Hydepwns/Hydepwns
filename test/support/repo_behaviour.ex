defmodule HydepwnsLiveview.TestRepoBehaviour do
  @moduledoc """
  Behaviour for Repo functions that can be mocked in tests.
  """

  @callback get(module, any, Keyword.t()) :: any
  @callback get!(module, any, Keyword.t()) :: any
  @callback get_by(module, Keyword.t(), Keyword.t()) :: any
  @callback get_by(module, Keyword.t()) :: any
end 