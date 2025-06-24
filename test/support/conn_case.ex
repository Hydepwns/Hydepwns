defmodule HydepwnsLiveviewWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use HydepwnsLiveviewWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import HydepwnsLiveviewWeb.ConnCase
      import Phoenix.Component

      # Ensure Router and its Helpers are compiled and available
      require HydepwnsLiveviewWeb.Router
      alias HydepwnsLiveviewWeb.Router.Helpers, as: Routes
      @phoenix_router HydepwnsLiveviewWeb.Router

      # The default endpoint for testing
      @endpoint HydepwnsLiveviewWeb.Endpoint

      # Add test routes
      setup do
        # Configure test routes
        Application.put_env(:hydepwns_liveview, HydepwnsLiveviewWeb.Router,
          live_routes: [
            {"/test-types", HydepwnsLiveviewWeb.TestTypeLive},
            {"/", HydepwnsLiveviewWeb.HomeLive}
          ]
        )

        :ok
      end
    end
  end

  setup tags do
    pid = HydepwnsLiveview.DataCase.setup_sandbox(tags)

    if tags[:liveview] do
      Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), pid)
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
