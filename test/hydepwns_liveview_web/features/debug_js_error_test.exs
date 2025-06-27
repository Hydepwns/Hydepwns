defmodule HydepwnsLiveviewWeb.DebugJSErrorTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false

  setup %{test: _test} do
    # Set up mocks before each test
    HydepwnsLiveviewWeb.TestMockHelper.setup_mocks()
    # Temporarily enable global mode for debugging
    Mox.set_mox_global(true)
    :ok
  end

  test "debug querySelectorAll error", %{session: session} do
    # Start with a simple page visit
    session = visit(session, "/resources")
    
    # Add JavaScript error logging before any actions
    Wallaby.Browser.execute_script(session, """
      window.addEventListener('error', function(e) {
        console.error('JavaScript Error:', e.error);
        console.error('Error message:', e.message);
        console.error('Error stack:', e.error ? e.error.stack : 'No stack');
        console.error('Error filename:', e.filename);
        console.error('Error lineno:', e.lineno);
        
        // Capture the call stack
        if (e.error && e.error.stack) {
          console.error('Full stack trace:', e.error.stack);
        }
        
        window.lastError = {
          message: e.message,
          stack: e.error ? e.error.stack : 'No stack',
          filename: e.filename,
          lineno: e.lineno
        };
      });
      
      // Also catch unhandled promise rejections
      window.addEventListener('unhandledrejection', function(e) {
        console.error('Unhandled Promise Rejection:', e.reason);
        window.lastPromiseError = e.reason;
      });
      
      // Override querySelectorAll to catch the invalid selector
      const originalQuerySelectorAll = document.querySelectorAll;
      document.querySelectorAll = function(selector) {
        if (selector === '#') {
          console.error('Invalid selector detected: "#"');
          console.error('Call stack:', new Error().stack);
          console.error('This selector was passed to querySelectorAll');
        }
        return originalQuerySelectorAll.apply(this, arguments);
      };
    """)
    
    # Try to trigger the error by navigating
    session
    |> click(button("Create Resource"))
    |> fill_in(text_field("resource[name]"), with: "Debug Test")
    |> fill_in(text_field("resource[description]"), with: "Debug test resource")
    |> set_value(select("resource[status]"), "published")
    |> click(button("Create Resource"))
    
    # Wait for any errors to occur
    Process.sleep(3000)
    
    # Check for errors
    errors = Wallaby.Browser.execute_script(session, "return window.lastError;")
    promise_errors = Wallaby.Browser.execute_script(session, "return window.lastPromiseError;")
    
    if errors do
      IO.inspect(errors, label: "JavaScript Errors")
    end
    
    if promise_errors do
      IO.inspect(promise_errors, label: "Promise Errors")
    end
    
    # Get console logs
    logs = Wallaby.Browser.execute_script(session, "return window.consoleLogs || [];")
    if logs && length(logs) > 0 do
      IO.inspect(logs, label: "Console Logs")
    end
    
    # Basic assertion to ensure the test completes
    page_source = Wallaby.Browser.page_source(session)
    assert page_source =~ "Resources" or page_source =~ "Debug Test"
  end

  test "minimal navigation test", %{session: session} do
    # Test simple navigation without form submission
    session = visit(session, "/")
    
    # Navigate directly to resources page since there's no navigation menu
    session = visit(session, "/resources")
    
    # Check if we can navigate without errors
    assert has_text?(session, "Resources")
    
    # Try clicking create button without filling form
    session = click(session, button("Create Resource"))
    
    # Should be on the form page
    assert has_text?(session, "Create Resource") or has_text?(session, "resource[name]")
  end
end 