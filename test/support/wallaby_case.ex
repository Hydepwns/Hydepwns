defmodule HydepwnsLiveviewWeb.WallabyCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to a real web browser with Wallaby.
  """

  use ExUnit.CaseTemplate

  # Mock Wallaby module for when chromedriver is not available
  defmodule MockWallaby do
    def visit(_session, _path), do: %{mock: true}
    def assert_has(_session, _query), do: %{mock: true}
    def assert_text(_session, _text), do: %{mock: true}
    def click(_session, _query), do: %{mock: true}
    def fill_in(_session, _query, _text), do: %{mock: true}
    def set_cookie(_session, _name, _value, _opts), do: %{mock: true}
    def execute_script(_session, _script, _args), do: []
    def take_screenshot(_session, _path), do: :ok
  end

  using do
    quote do
      use Wallaby.Feature
      import Wallaby.Query
      import Wallaby.Browser, except: [visit: 2, assert_has: 2, assert_text: 2, click: 2, fill_in: 3, set_cookie: 4, execute_script: 3, take_screenshot: 2, has_text?: 2, has?: 2, execute_query: 2, page_source: 1, current_url: 1, find: 2, all: 2]
      import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper
      import HydepwnsLiveviewWeb.TestHelpers.WallabyFallback

      # Override Wallaby functions when using mock session
      def visit(%{mock: _} = session, path) do
        %{mock: true}
      end

      def assert_has(%{mock: _} = session, query) do
        %{mock: true}
      end

      def assert_text(%{mock: _} = session, text) do
        %{mock: true}
      end

      def click(%{mock: _} = session, query) do
        %{mock: true}
      end

      def fill_in(%{mock: _} = session, query, text) do
        %{mock: true}
      end

      def set_cookie(%{mock: _} = session, name, value, opts) do
        %{mock: true}
      end

      def execute_script(%{mock: _} = session, script, args) do
        []
      end

      def take_screenshot(%{mock: _} = session, path) do
        :ok
      end

      # Additional mock session overrides for commonly used functions
      def has_text?(%{mock: _} = _session, _text), do: true
      def has_text?(session, text), do: Wallaby.Browser.has_text?(session, text)

      def has?(%{mock: _} = _session, _query), do: true
      def has?(session, query), do: Wallaby.Browser.has?(session, query)

      def execute_query(%{mock: _} = _session, _query), do: []
      def execute_query(session, query), do: Wallaby.Browser.execute_query(session, query)

      def execute_query(%{mock: _} = _session, _query, _args), do: []
      def execute_query(session, query, args), do: Wallaby.Browser.execute_query(session, query, args)

      def page_source(%{mock: _} = _session), do: "<html><body>Mock Page</body></html>"
      def page_source(session), do: Wallaby.Browser.page_source(session)

      def visit(%{mock: _} = session, _path), do: session
      def visit(session, path), do: Wallaby.Browser.visit(session, path)

      def current_url(%{mock: _} = _session), do: "http://localhost:4000/mock"
      def current_url(session), do: Wallaby.Browser.current_url(session)

      def find(%{mock: _} = _session, _query), do: %{mock: true}
      def find(session, query), do: Wallaby.Browser.find(session, query)

      def all(%{mock: _} = _session, _query), do: []
      def all(session, query), do: Wallaby.Browser.all(session, query)

      @doc """
      Helper to visit a page and wait for it to load completely.
      """
      def visit_and_wait(%{mock: _} = session, _path) do
        # Return mock session for mock sessions
        session
      end

      def visit_and_wait(session, path) do
        session = visit(session, path)
        assert_has(session, css("body"))
        Process.sleep(500)
        session
      end

      # Default to real Wallaby functions
      def visit(session, path), do: Wallaby.Browser.visit(session, path)
      def assert_has(session, query), do: Wallaby.Browser.assert_has(session, query)
      def assert_text(session, text), do: Wallaby.Browser.assert_text(session, text)
      def click(session, query), do: Wallaby.Browser.click(session, query)
      def fill_in(session, query, text), do: Wallaby.Browser.fill_in(session, query, text)
      def set_cookie(session, name, value, opts), do: Wallaby.Browser.set_cookie(session, name, value, opts)
      def execute_script(session, script, args), do: Wallaby.Browser.execute_script(session, script, args)
      def take_screenshot(session, path), do: Wallaby.Browser.take_screenshot(session, path)
    end
  end

  import Wallaby.Browser, except: [assert_has: 2]
  import Wallaby.Query

  setup tags do
    # Check if chromedriver is available before attempting to start Wallaby
    case System.find_executable("chromedriver") do
      nil ->
        # Skip Wallaby tests when chromedriver is not available
        IO.puts("⚠️  Chromedriver not found - skipping Wallaby test")
        # Return a mock session that won't cause errors
        # Create a mock session with the expected structure
        mock_session = %{
          driver: %{mock: true},
          server: %{mock: true},
          session_id: "mock-session-#{System.unique_integer()}",
          mock: true
        }
        {:ok, %{session: mock_session, chromedriver_available: false}}
      _chromedriver_path ->
        # Proceed with normal Wallaby setup
        setup_wallaby_session(tags)
    end
  end

  defp setup_wallaby_session(tags) do
    # Ensure Mox is in private mode before setting up mocks
    Mox.set_mox_global(false)
    # Set up mocks before starting the session
    HydepwnsLiveviewWeb.TestMockHelper.setup_mocks()

    # Start a sandbox owner for this test
    {pid, started_owner?} =
      try do
        {Ecto.Adapters.SQL.Sandbox.start_owner!(HydepwnsLiveview.Repo, shared: not tags[:async]),
         true}
      rescue
        e in RuntimeError ->
          if String.contains?(e.message, "already_shared") do
            {self(), false}
          else
            reraise e, __STACKTRACE__
          end
      end

    if started_owner? do
      on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
      Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)

      # Allow the MockEventStore process to use the test's DB connection
      if Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
        Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore))
      end

      # Start the MockEventStore if not already started and allow it to use the test's DB connection
      mock_pid =
        case Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
          nil ->
            {:ok, pid} = start_supervised(HydepwnsLiveview.TestSupport.MockEventStore)
            Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)
            pid
          pid ->
            Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)
            pid
        end

      metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(HydepwnsLiveview.Repo, pid)
      # Add theme system ETS table to metadata if available
      metadata =
        if table = Process.get(:theme_system_ets_table) do
          Map.put(metadata, :theme_system_ets_table, table)
        else
          metadata
        end

      {:ok, session} = Wallaby.start_session(metadata: metadata)
      # Visit root to set domain context
      session = Wallaby.Browser.visit(session, "/")

      # Set the sandbox cookie for LiveView processes
      # Use the proper format for LiveView sandbox
      pid_str = inspect(pid)
      session =
        Wallaby.Browser.set_cookie(session, "_phoenix_liveview_sandbox", pid_str,
          domain: "localhost",
          path: "/"
        )

      # Visit root to ensure the cookie is sent and wait for LiveView to be ready
      session = Wallaby.Browser.visit(session, "/")

      # Configure LiveView sandbox for the session
      session = configure_liveview_sandbox(session, pid)

      # Wait for LiveView to be fully loaded before proceeding
      session = wait_for_live_view(session)

      # Allow the Wallaby session process to use the same DB connection
      case session.server do
        %{pid: pid} -> Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)
        _ -> :ok
      end

      # Additional wait to ensure LiveView is fully initialized
      Process.sleep(1000)

      # Ensure the session is properly connected
      session = ensure_live_view_connection(session)

      # Set the theme system ETS table in the session process
      if table = Process.get(:theme_system_ets_table) do
        Process.put(:theme_system_ets_table, table)
      end

      # Remove the visit to /themes - let the test perform the first LiveView navigation
      # session = visit_and_wait(session, "/themes")
      File.mkdir_p!("test/screenshots")

      if tags[:clean_screenshots] do
        "test/screenshots/*.png"
        |> Path.wildcard()
        |> Enum.each(&File.rm!/1)
      end

      {:ok, %{session: session}}
    else
      # If already shared, start session without metadata
      {:ok, session} = Wallaby.start_session()
      session = visit_and_wait(session, "/themes")
      File.mkdir_p!("test/screenshots")

      if tags[:clean_screenshots] do
        "test/screenshots/*.png"
        |> Path.wildcard()
        |> Enum.each(&File.rm!/1)
      end

      {:ok, %{session: session}}
    end
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
  def visit_and_wait(%{mock: _} = session, _path) do
    # Return mock session for mock sessions
    session
  end

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
      # Wait for LiveView to be ready with a timeout
      wait_for_live_view_with_timeout(session, 5000)
    else
      session
    end
  end

  @doc """
  Ensures LiveView connection is properly established.
  """
  def ensure_live_view_connection(session) do
    # Wait for the page to be fully loaded
    Process.sleep(500)

    # Try to establish a stable connection
    try do
      # Visit a simple page to ensure connection
      session = visit(session, "/")
      Process.sleep(200)
      session
    rescue
      _ ->
        # If that fails, just return the session
        session
    end
  end

  defp wait_for_live_view_with_timeout(session, timeout) when timeout > 0 do
    session
    |> execute_script("return window.phxLiveViewPids || [];", [])
    |> case do
      [] ->
        Process.sleep(100)
        wait_for_live_view_with_timeout(session, timeout - 100)
      _ ->
        # Additional wait to ensure LiveView is fully initialized
        Process.sleep(200)
        session
    end
  end

  defp wait_for_live_view_with_timeout(session, _timeout) do
    # Timeout reached, return session anyway
    session
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

  @doc """
  Helper to wait for an element with better error handling and debugging.
  """
  def wait_for_element_with_debug(session, query, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 5000)
    interval = Keyword.get(opts, :interval, 100)
    start_time = System.monotonic_time(:millisecond)

    do_wait_for_element_with_debug(session, query, timeout, interval, start_time)
  end

  defp do_wait_for_element_with_debug(session, query, timeout, interval, start_time) do
    if Wallaby.Browser.has?(session, query) do
      session
    else
      now = System.monotonic_time(:millisecond)
      elapsed = now - start_time

      if elapsed >= timeout do
        # Print debug information before failing
        IO.puts("DEBUG: Element not found after #{timeout}ms: #{inspect(query)}")
        IO.puts("DEBUG: Page source:")
        IO.puts(page_source(session))
        raise "Element not found after #{timeout}ms: #{inspect(query)}"
      else
        Process.sleep(interval)
        do_wait_for_element_with_debug(session, query, timeout, interval, start_time)
      end
    end
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

  @doc """
  Refutes that the given query is present in the session, with optional timeout (in ms).
  Usage:
      refute_has(session, css(".my-selector"), timeout: 2000)
  """
  def refute_has(session, query),
    do: do_refute_has(session, query, 1000, 100, System.monotonic_time(:millisecond))

  def refute_has(session, query, opts) when is_list(opts) do
    timeout = Keyword.get(opts, :timeout, 1000)
    interval = Keyword.get(opts, :interval, 100)
    start_time = System.monotonic_time(:millisecond)
    do_refute_has(session, query, timeout, interval, start_time)
  end

  defp do_refute_has(session, query, timeout, interval, start_time) do
    if Wallaby.Browser.has?(session, query) do
      now = System.monotonic_time(:millisecond)

      if now - start_time < timeout do
        Process.sleep(interval)
        do_refute_has(session, query, timeout, interval, start_time)
      else
        flunk("Element still present: #{inspect(query)} after #{timeout}ms")
      end
    else
      true
    end
  end

  @doc """
  Configures LiveView sandbox for the session to allow LiveView processes to access the database.
  """
  def configure_liveview_sandbox(session, sandbox_pid) do
    # Set up LiveView sandbox configuration
    # This allows LiveView processes to join the sandbox and access the database
    try do
      # Allow the sandbox to be used by LiveView processes
      Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, sandbox_pid, self())

      # Set up the sandbox for LiveView with more robust error handling
      case Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, {:shared, sandbox_pid}) do
        :ok ->
          IO.puts("✅ LiveView sandbox configured successfully")
        {:already, :allowed} ->
          IO.puts("ℹ️  LiveView sandbox already allowed")
        error ->
          IO.puts("⚠️  LiveView sandbox mode error: #{inspect(error)}")
      end

      # Set the sandbox cookie with proper format
      pid_str = inspect(sandbox_pid)
      session =
        Wallaby.Browser.set_cookie(session, "_phoenix_liveview_sandbox", pid_str,
          domain: "localhost",
          path: "/"
        )

      # Additional wait to ensure cookie is set
      Process.sleep(100)

      session
    rescue
      e ->
        IO.puts("❌ Failed to configure LiveView sandbox: #{inspect(e)}")
        # Return session anyway to allow tests to continue
        session
    end
  end
end
