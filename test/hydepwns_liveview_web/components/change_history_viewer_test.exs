defmodule HydepwnsLiveviewWeb.Components.ChangeHistoryViewerTest do
  use ExUnit.Case, async: true
  @endpoint HydepwnsLiveviewWeb.Endpoint
  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.Components.ChangeHistoryViewer
  import Phoenix.ConnTest

  @moduletag :component

  describe "change_history_viewer/1" do
    test "renders empty state when no history" do
      html =
        render_component(&change_history_viewer/1, %{resource: %{__change_history__: []}})

      assert html =~ "No changes tracked yet"
    end

    test "renders timeline view with history" do
      history = [
        %{
          version: 1,
          changes: %{name: "A"},
          metadata: %{timestamp: ~N[2024-01-01 00:00:00], actor: "user1", reason: "init"}
        },
        %{
          version: 2,
          changes: %{name: "B"},
          metadata: %{timestamp: ~N[2024-01-02 00:00:00], actor: "user2", reason: "update"}
        }
      ]

      resource = %{__change_history__: history}

      html =
        render_component(&change_history_viewer/1, %{resource: resource, view_mode: "timeline"})

      assert html =~ "Change History"
      assert html =~ "Timeline"
      assert html =~ "Version 1"
      assert html =~ "Version 2"
    end

    test "renders list view with history" do
      history = [
        %{
          version: 1,
          changes: %{name: "A"},
          metadata: %{timestamp: ~N[2024-01-01 00:00:00], actor: "user1", reason: "init"}
        }
      ]

      resource = %{__change_history__: history}

      html =
        render_component(&change_history_viewer/1, %{resource: resource, view_mode: "list"})

      assert html =~ "List"
      assert html =~ "Version"
      assert html =~ "user1"
    end

    test "renders audit log view with history" do
      history = [
        %{
          version: 1,
          changes: %{name: "A"},
          before: %{},
          metadata: %{
            timestamp: ~N[2024-01-01 00:00:00],
            actor: "user1",
            reason: "init",
            source: "test"
          }
        }
      ]

      resource = %{__change_history__: history}

      html =
        render_component(&change_history_viewer/1, %{resource: resource, view_mode: "audit"})

      assert html =~ "Audit Log"
      assert html =~ "Actor: user1"
      assert html =~ "Source: test"
    end

    test "renders correct phx-click and phx-value for view mode buttons" do
      html =
        render_component(&change_history_viewer/1, %{
          resource: %{
            __change_history__: [
              %{
                version: 1,
                changes: %{},
                metadata: %{timestamp: ~N[2024-01-01 00:00:00], actor: "a", reason: "r"}
              }
            ]
          }
        })

      assert html =~ ~s(phx-click="set_view_mode" phx-value-mode="timeline")
      assert html =~ ~s(phx-click="set_view_mode" phx-value-mode="list")
      assert html =~ ~s(phx-click="set_view_mode" phx-value-mode="audit")
    end

    test "renders correct phx-click and phx-value for view and diff buttons in list view" do
      history = [
        %{
          version: 1,
          changes: %{name: "A"},
          metadata: %{timestamp: ~N[2024-01-01 00:00:00], actor: "user1", reason: "init"}
        },
        %{
          version: 2,
          changes: %{name: "B"},
          metadata: %{timestamp: ~N[2024-01-02 00:00:00], actor: "user2", reason: "update"}
        }
      ]

      resource = %{__change_history__: history}

      html =
        render_component(&change_history_viewer/1, %{
          resource: resource,
          view_mode: "list",
          selected_version: 1,
          on_view_version: "view_version",
          on_diff_versions: "diff_versions"
        })

      # View button for version 2
      assert html =~ ~s(phx-click="view_version" phx-value-version="2")
      # Diff button for version 2
      assert html =~ ~s(phx-click="diff_versions" phx-value-version1="1" phx-value-version2="2")
    end

    test "renders correct phx-click and phx-value for view and compare buttons in audit view" do
      history = [
        %{
          version: 1,
          changes: %{name: "A"},
          before: %{},
          metadata: %{
            timestamp: ~N[2024-01-01 00:00:00],
            actor: "user1",
            reason: "init",
            source: "test"
          }
        },
        %{
          version: 2,
          changes: %{name: "B"},
          before: %{},
          metadata: %{
            timestamp: ~N[2024-01-02 00:00:00],
            actor: "user2",
            reason: "update",
            source: "test"
          }
        }
      ]

      resource = %{__change_history__: history}

      html =
        render_component(&change_history_viewer/1, %{
          resource: resource,
          view_mode: "audit",
          selected_version: 1,
          on_view_version: "view_version",
          on_diff_versions: "diff_versions"
        })

      # View button for version 2
      assert html =~ ~s(phx-click="view_version" phx-value-version="2")
      # Compare button for version 2
      assert html =~ ~s(phx-click="diff_versions" phx-value-version1="1" phx-value-version2="2")
    end
  end

  describe "integration: event propagation" do
    defmodule TestLive do
      use Phoenix.LiveView
      import HydepwnsLiveviewWeb.Components.ChangeHistoryViewer

      def render(assigns) do
        ~H"""
        <.change_history_viewer resource={@resource} selected_version={@selected_version} on_view_version="view_version" on_diff_versions="diff_versions" view_mode={@view_mode} />
        <div id="event-log">{@event_log}</div>
        """
      end

      def mount(_params, _session, socket) do
        {:ok,
         assign(socket,
           resource: %{
             __change_history__: [
               %{
                 version: 1,
                 changes: %{name: "A"},
                 metadata: %{timestamp: ~N[2024-01-01 00:00:00], actor: "user1", reason: "init"}
               },
               %{
                 version: 2,
                 changes: %{name: "B"},
                 metadata: %{timestamp: ~N[2024-01-02 00:00:00], actor: "user2", reason: "update"}
               }
             ]
           },
           selected_version: 1,
           view_mode: "list",
           event_log: ""
         )}
      end

      def handle_event("view_version", %{"version" => version}, socket) do
        {:noreply, assign(socket, event_log: "view_version:#{version}")}
      end

      def handle_event("diff_versions", %{"version1" => v1, "version2" => v2}, socket) do
        {:noreply, assign(socket, event_log: "diff_versions:#{v1}-#{v2}")}
      end
    end

    test "clicking view and diff buttons emits events to parent LiveView" do
      {:ok, view, _html} = live_isolated(build_conn(), TestLive)
      # Click the view button for version 2
      view
      |> element("button[phx-click=\"view_version\"][phx-value-version=\"2\"]")
      |> render_click()

      assert render(view) =~ "view_version:2"
      # Click the diff button for version 2
      view
      |> element(
        "button[phx-click=\"diff_versions\"][phx-value-version1=\"1\"][phx-value-version2=\"2\"]"
      )
      |> render_click()

      assert render(view) =~ "diff_versions:1-2"
    end
  end
end
