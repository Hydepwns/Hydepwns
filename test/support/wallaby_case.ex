defmodule HydepwnsLiveviewWeb.WallabyCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to a real web browser with Wallaby.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      use Wallaby.Feature

      import Phoenix.LiveViewTest
      import Wallaby.Query
      import HydepwnsLiveviewWeb.WallabyCase
      import HydepwnsLiveviewWeb.VisualRegressionHelper

      alias HydepwnsLiveviewWeb.Router.Helpers, as: Routes

      @endpoint HydepwnsLiveviewWeb.Endpoint
    end
  end

  import Wallaby.Browser
  import Wallaby.Query

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(HydepwnsLiveview.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(HydepwnsLiveview.Repo, pid)

    {:ok, session} = Wallaby.start_session(metadata: metadata)

    # Create screenshots directory if it doesn't exist
    File.mkdir_p!("test/screenshots")

    # Clean up previous screenshots if requested
    if tags[:clean_screenshots] do
      "test/screenshots/*.png"
      |> Path.wildcard()
      |> Enum.each(&File.rm!/1)
    end

    {:ok, %{session: session}}
  end

  @doc """
  Helper to create a complete test screenshot name with timestamp to avoid overwriting.
  """
  def screenshot_name(base_name) do
    timestamp = DateTime.utc_now() |> DateTime.to_string() |> String.replace(~r/[^0-9]/, "")
    "#{base_name}_#{timestamp}"
  end

  @doc """
  Helper to visit a page and wait for it to load completely.
  """
  def visit_and_wait(session, path) do
    session =
      session
      |> visit(path)
      |> assert_has(css("body"))

    # Wait for animations, lazy loading, etc.

    Process.sleep(500)

    session
  end

  @doc """
  Helper to wait for LiveView to be fully loaded.
  """
  def wait_for_live_view(session) do
    session =
      session
      |> assert_has(css("body[data-phx-session]"))

    # Give LiveView time to initialize 

    Process.sleep(300)

    session
  end
end
