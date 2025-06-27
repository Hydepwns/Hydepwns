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
    end
  end

  import Wallaby.Browser, except: [assert_has: 2]
  import Wallaby.Query

  setup tags do
    # Set up mocks before starting the session
    HydepwnsLiveviewWeb.TestMockHelper.setup_mocks()
    
    # Start a sandbox owner for this test
    pid = try do
      Ecto.Adapters.SQL.Sandbox.start_owner!(HydepwnsLiveview.Repo, shared: not tags[:async])
    rescue
      e in RuntimeError ->
        if String.contains?(e.message, "already_shared") do
          # Sandbox is already shared, use the current process
          self()
        else
          reraise e, __STACKTRACE__
        end
    end
    
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    
    # Allow the current process to use the sandbox
    Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)

    # Create metadata for the sandbox
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(HydepwnsLiveview.Repo, pid)
    {:ok, session} = Wallaby.start_session(metadata: metadata)

    # Visit a default page to ensure LiveView is started and expose the PID
    session = visit_and_wait(session, "/themes")

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
    session = visit(session, path)
    assert_has(session, css("body"))
    Process.sleep(500)
    session
  end

  @doc """
  Helper to wait for LiveView to be fully loaded.
  """
  def wait_for_live_view(session) do
    if session do
      session
      |> execute_script("return window.phxLiveViewPids || [];", [])
      |> case do
        [] -> Process.sleep(100) && wait_for_live_view(session)
        _ -> session
      end
    else
      session
    end
  end

  @doc """
  Helper to wait for a form to be fully rendered and interactive.
  """
  def wait_for_form(session, form_id) do
    session
    |> assert_has(css("##{form_id}"))
    |> assert_has(css("##{form_id} input"))
    |> wait_for_live_view()
  end

  @doc """
  Helper to fill in a form field and wait for validation.
  """
  def fill_form_field(session, form_id, field_name, value) do
    session
    |> fill_in(css("##{form_id} ##{field_name}"), with: value)
    |> wait_for_live_view()
  end

  @doc """
  Asserts that the given query is present in the session, with optional timeout (in ms).
  Usage:
      assert_has(session, css(".my-selector"), timeout: 2000)
  """
  def assert_has(session, query), do: Wallaby.Browser.has?(session, query)

  def assert_has(session, query, opts) when is_list(opts) do
    timeout = Keyword.get(opts, :timeout, 1000)
    interval = Keyword.get(opts, :interval, 100)
    start_time = System.monotonic_time(:millisecond)

    do_assert_has(session, query, timeout, interval, start_time)
  end

  defp do_assert_has(session, query, timeout, interval, start_time) do
    if Wallaby.Browser.has?(session, query) do
      true
    else
      now = System.monotonic_time(:millisecond)

      if now - start_time < timeout do
        Process.sleep(interval)
        do_assert_has(session, query, timeout, interval, start_time)
      else
        flunk("Element not found: #{inspect(query)} after #{timeout}ms")
      end
    end
  end
end
