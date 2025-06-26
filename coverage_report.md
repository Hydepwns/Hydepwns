# Coverage Report - 2025-06-26 11:29:41.728563Z

## Summary
- Total Tests: 0
- Passing Tests: -8
- Failing Tests: 0
- Skipped Tests: 8
- Coverage: 0.0%

## Module Coverage
- hydepwns_liveview_web.features: 89 tests
- hydepwns_liveview_web.live: 34 tests
- hydepwns_liveview.theme_system: 20 tests
- : 9 tests
- hydepwns_liveview_web.components: 8 tests
- hydepwns_liveview.events: 6 tests
- hydepwns_liveview.theme_system_test.exs:30: 1 tests
- hydepwns_liveview.theme_system_test.exs:33: (test): 1 tests
- socket_validator.type_validation_test.exs:113: (test): 1 tests
- socket_validator.type_validation_test.exs:190: 1 tests
- socket_validator.type_validation_test.exs:209: (test): 1 tests
- socket_validator.type_validation_test.exs:334: 1 tests
- socket_validator.type_validation_test.exs:405: (test): 1 tests
- socket_validator.type_validation_test.exs:415: 1 tests
- socket_validator.type_validation_test.exs:451: (test): 1 tests
- socket_validator.type_validation_test.exs:472: 1 tests
- socket_validator.type_validation_test.exs:498: (test): 1 tests
- socket_validator.type_validation_test.exs:501: 1 tests
- socket_validator.type_validation_test.exs:512: (test): 1 tests
- socket_validator.type_validation_test.exs:531: anonymous fn: 1 tests
- socket_validator.type_validation_test.exs:59: 1 tests

## Raw Test Output
```
make: Nothing to be done for `build'.
===> Analyzing applications...
===> Compiling libsignal_protocol_nif

  ../priv/static/assets/app.js  262.1kb

⚡ Done in 48ms
     warning: function __relationship_belongs_to__/2 is unused
     │
 564 │   defp __relationship_belongs_to__(name, resource) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:564:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_belongs_to_with_opts__/3 is unused
     │
 576 │   defp __relationship_belongs_to_with_opts__(name, resource, opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:576:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_many__/2 is unused
     │
 588 │   defp __relationship_has_many__(name, resource) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:588:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_many_through__/2 is unused
     │
 612 │   defp __relationship_has_many_through__(name, opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:612:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_many_through_with_opts__/3 is unused
     │
 630 │   defp __relationship_has_many_through_with_opts__(name, opts, through_opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:630:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_many_with_opts__/3 is unused
     │
 600 │   defp __relationship_has_many_with_opts__(name, resource, opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:600:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_one__/2 is unused
     │
 648 │   defp __relationship_has_one__(name, resource) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:648:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_one_through__/2 is unused
     │
 672 │   defp __relationship_has_one_through__(name, opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:672:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_one_through_with_opts__/3 is unused
     │
 690 │   defp __relationship_has_one_through_with_opts__(name, opts, through_opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:690:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_has_one_with_opts__/3 is unused
     │
 660 │   defp __relationship_has_one_with_opts__(name, resource, opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:660:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_polymorphic__/2 is unused
     │
 708 │   defp __relationship_polymorphic__(name, opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:708:8: HydepwnsLiveview.Utils.LiveViewResource (module)

     warning: function __relationship_polymorphic_with_opts__/3 is unused
     │
 725 │   defp __relationship_polymorphic_with_opts__(name, opts, poly_opts) do
     │        ~
     │
     └─ lib/hydepwns_liveview/utils/live_view_resource.ex:725:8: HydepwnsLiveview.Utils.LiveViewResource (module)

    warning: def store_event/2 has multiple clauses and also declares default values. In such cases, the default values should be defined in a header. Instead of:

        def foo(:first_clause, b \\ :default) do ... end
        def foo(:second_clause, b) do ... end

    one should write:

        def foo(a, b \\ :default)
        def foo(:first_clause, b) do ... end
        def foo(:second_clause, b) do ... end

    │
 29 │   def store_event(type, data) do
    │       ~
    │
    └─ test/support/mock_event_store.ex:29:7

     warning: function _assert_dynamic_focus/1 is unused
     │
 342 │   defp _assert_dynamic_focus(view) do
     │        ~
     │
     └─ test/support/accessibility_helper.ex:342:8: HydepwnsLiveviewWeb.AccessibilityHelper (module)

     warning: function _assert_focus_indicators/1 is unused
     │
 335 │   defp _assert_focus_indicators(view) do
     │        ~
     │
     └─ test/support/accessibility_helper.ex:335:8: HydepwnsLiveviewWeb.AccessibilityHelper (module)

     warning: function _assert_focus_restoration/1 is unused
     │
 329 │   defp _assert_focus_restoration(view) do
     │        ~
     │
     └─ test/support/accessibility_helper.ex:329:8: HydepwnsLiveviewWeb.AccessibilityHelper (module)

     warning: function _assert_modal_focus_trap/1 is unused
     │
 319 │   defp _assert_modal_focus_trap(view) do
     │        ~
     │
     └─ test/support/accessibility_helper.ex:319:8: HydepwnsLiveviewWeb.AccessibilityHelper (module)

13:29:00.665 [info] Running HydepwnsLiveviewWeb.Endpoint with Bandit 1.7.0 at 127.0.0.1:4002 (http)
13:29:00.675 [info] Access HydepwnsLiveviewWeb.Endpoint at http://localhost:4002
Running ExUnit with seed: 745014, max_cases: 16

........13:29:08.687 request_id=GEyUPeHE-IQaXdYAAADI [info] GET /style-guide
.......13:29:08.872 request_id=GEyUPe96zCR80lcAAABl [info] GET /style-guide
13:29:08.881 request_id=GEyUPfANq5ZY_RUAAAQk [info] GET /style-guide
.13:29:09.053 request_id=GEyUPfpI_x0r-zoAAAYB [info] GET /
...********..

  1) test integration: event propagation clicking view and diff buttons emits events to parent LiveView (HydepwnsLiveviewWeb.Components.ChangeHistoryViewerTest)
     test/hydepwns_liveview_web/components/change_history_viewer_test.exs:239
     ** (RuntimeError) no @endpoint set in test module
     code: {:ok, view, _html} = live_isolated(build_conn(), TestLive)
     stacktrace:
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/test/live_view_test.ex:280: anonymous fn/2 in Phoenix.LiveViewTest.__isolated__/4
       (elixir 1.17.1) lib/map.ex:957: Map.get_and_update/3
       (elixir 1.17.1) lib/map.ex:999: Map.get_and_update!/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/test/live_view_test.ex:280: Phoenix.LiveViewTest.__isolated__/4
       test/hydepwns_liveview_web/components/change_history_viewer_test.exs:240: (test)

...........

  2) test list/1 renders a list (HydepwnsLiveviewWeb.Components.CoreComponentsTest)
     test/hydepwns_liveview_web/components/core_components_test.exs:213
     Assertion with =~ failed
     code:  assert html =~ "First"
     left:  "<ul class=\"list \">\n  \n</ul>"
     right: "First"
     stacktrace:
       test/hydepwns_liveview_web/components/core_components_test.exs:222: (test)



  3) test button/1 renders a button (HydepwnsLiveviewWeb.Components.CoreComponentsTest)
     test/hydepwns_liveview_web/components/core_components_test.exs:37
     Assertion with =~ failed
     code:  assert html =~ "Click me"
     left:  "<button type=\"submit\" class=\"my-btn\">\n  \n</button>"
     right: "Click me"
     stacktrace:
       test/hydepwns_liveview_web/components/core_components_test.exs:46: (test)

..

  4) test simple_form/1 renders a simple form (HydepwnsLiveviewWeb.Components.CoreComponentsTest)
     test/hydepwns_liveview_web/components/core_components_test.exs:104
     Assertion with =~ failed
     code:  assert html =~ "Form Field"
     left:  "<form>\n  \n  \n  \n  \n  <div class=\"flex justify-end gap-3\">\n    \n  </div>\n\n</form>"
     right: "Form Field"
     stacktrace:
       test/hydepwns_liveview_web/components/core_components_test.exs:115: (test)

.........DEBUG: nav component called with assigns: [:__changed__]
DEBUG: nav slot content: ""
....................................................

  5) test processes due reminders (HydepwnsLiveview.Events.ReminderWorkerTest)
     test/hydepwns_liveview/events/reminder_worker_test.exs:53
     Assertion with == failed
     code:  assert updated_reminder.status == "sent"
     left:  "pending"
     right: "sent"
     stacktrace:
       test/hydepwns_liveview/events/reminder_worker_test.exs:59: (test)

.........

  6) test BaseLive integration with type validation validates types during mount lifecycle (HydepwnsLiveview.TypeValidationTest)
     test/socket_validator/type_validation_test.exs:415
     Assertion with == failed
     code:  assert assigns.string_value == "test string"
     left:  "default"
     right: "test string"
     stacktrace:
       test/socket_validator/type_validation_test.exs:451: (test)

     The following output was logged:
     13:29:09.186 request_id=GEyUPgI7kLmus5AAAARE [info] GET /test-types
     13:29:09.352 request_id=GEyUPgwezKf2ksQAAAJj [info] GET /resources/123
     13:29:09.989 request_id=GEyUPfpI_x0r-zoAAAYB [debug] Processing with HydepwnsLiveviewWeb.HomeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:09.989 request_id=GEyUPfANq5ZY_RUAAAQk [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:09.989 request_id=GEyUPeHE-IQaXdYAAADI [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:09.989 request_id=GEyUPe96zCR80lcAAABl [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:09.990 request_id=GEyUPgI7kLmus5AAAARE [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:10.227 request_id=GEyUPgwezKf2ksQAAAJj [debug] Processing with HydepwnsLiveviewWeb.ResourceShowLive.show/2
       Parameters: %{"id" => "123"}
       Pipelines: [:browser]
     13:29:10.965 request_id=GEyUPmw4n7bBEnoAAATE [info] GET /
     13:29:10.966 request_id=GEyUPmw4n7bBEnoAAATE [debug] Processing with HydepwnsLiveviewWeb.HomeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:11.848 request_id=GEyUPqDfzfVaJmoAAADn [info] GET /
     13:29:11.850 request_id=GEyUPqDfzfVaJmoAAADn [debug] Processing with HydepwnsLiveviewWeb.HomeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:12.170 [debug] QUERY OK source="events" db=446.6ms decode=125.9ms queue=149.4ms
     INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["d2a91962-6c05-44b0-a90d-a26f4644b590", %{data: %{description: "Test Description", end_time: ~U[2025-06-26 13:29:09.041637Z], start_time: ~U[2025-06-26 12:29:08.926219Z], title: "Test Event"}, resource_id: "ea36c92a-b707-4ab8-8584-890074a069ed", resource_type: "calendar_event"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:09.168363Z], "calendar_event.created", ~U[2025-06-26 11:29:10.935107Z], ~U[2025-06-26 11:29:10.935107Z], "151497ff-0e9a-4e5e-8678-4fc1e54e832e"]
     13:29:12.228 request_id=GEyUPreEHbuxIFYAAAHn [info] GET /
     13:29:12.228 request_id=GEyUPreEHbuxIFYAAAHn [debug] Processing with HydepwnsLiveviewWeb.HomeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:12.280 [debug] QUERY OK source="event_settings" db=10.1ms queue=1.0ms
     INSERT INTO "event_settings" ("default_duration","default_status","enable_reminders","event_id","max_events_per_day","reminder_time","timezone","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING "id" [60, "draft", true, "151497ff-0e9a-4e5e-8678-4fc1e54e832e", 10, 30, "UTC", ~N[2025-06-26 11:29:12], ~N[2025-06-26 11:29:12]]
     13:29:12.286 request_id=GEyUPmw4n7bBEnoAAATE [info] Sent 200 in 1321ms
     13:29:12.287 request_id=GEyUPgI7kLmus5AAAARE [info] Sent 200 in 3101ms
     13:29:12.287 request_id=GEyUPfANq5ZY_RUAAAQk [info] Sent 200 in 3406ms
     13:29:12.287 request_id=GEyUPe96zCR80lcAAABl [info] Sent 200 in 3415ms
     13:29:12.287 request_id=GEyUPfpI_x0r-zoAAAYB [info] Sent 200 in 3234ms
     13:29:12.287 request_id=GEyUPqDfzfVaJmoAAADn [info] Sent 200 in 439ms
     13:29:12.288 request_id=GEyUPeHE-IQaXdYAAADI [info] Sent 200 in 3601ms
     13:29:12.297 request_id=GEyUPreEHbuxIFYAAAHn [info] Sent 200 in 69ms
     13:29:12.322 [debug] QUERY OK source="event_reminders" db=2.3ms queue=0.5ms
     INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["151497ff-0e9a-4e5e-8678-4fc1e54e832e", "test@example.com", ~U[2025-06-26 11:28:12Z], "pending", ~N[2025-06-26 11:29:12], ~N[2025-06-26 11:29:12]]
     13:29:12.323 [debug] QUERY OK source="event_reminders" db=0.4ms
     INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["151497ff-0e9a-4e5e-8678-4fc1e54e832e", "test@example.com", ~U[2025-06-26 12:29:12Z], "pending", ~N[2025-06-26 11:29:12], ~N[2025-06-26 11:29:12]]
     13:29:12.417 request_id=GEyUPsLR7wV-bm0AAAWE [info] GET /style-guide
     13:29:12.418 request_id=GEyUPsLR7wV-bm0AAAWE [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:12.418 request_id=GEyUPsLR7wV-bm0AAAWE [info] Sent 200 in 663µs
     13:29:12.549 request_id=GEyUPsqyswMPCyIAAAYE [info] GET /test-resource-live
     13:29:12.550 request_id=GEyUPsqyswMPCyIAAAYE [debug] Processing with HydepwnsLiveviewWeb.TestResourceLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:12.730 [debug] QUERY OK source="event_reminders" db=2.0ms queue=3.1ms
     SELECT e0."id", e0."reminder_time", e0."status", e0."recipient", e0."sent_at", e0."error_message", e0."event_id", e0."inserted_at", e0."updated_at" FROM "event_reminders" AS e0 WHERE (e0."id" = $1) [326]
     13:29:12.789 [debug] QUERY OK source="events" db=0.8ms queue=2.9ms
     INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["bad1352f-31eb-4086-9e9d-173ce76724d7", %{data: %{description: "Test Description", end_time: ~U[2025-06-26 13:29:12.785478Z], start_time: ~U[2025-06-26 12:29:12.785353Z], title: "Test Event"}, resource_id: "a97434ad-5932-44e1-ad4c-f06cadfa366f", resource_type: "calendar_event"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:12.785502Z], "calendar_event.created", ~U[2025-06-26 11:29:12.785558Z], ~U[2025-06-26 11:29:12.785558Z], "b7f6a08b-d528-4731-adaf-0dcff9afb501"]
     13:29:12.795 [debug] QUERY OK source="event_settings" db=3.6ms queue=0.7ms
     INSERT INTO "event_settings" ("default_duration","default_status","enable_reminders","event_id","max_events_per_day","reminder_time","timezone","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING "id" [60, "draft", true, "b7f6a08b-d528-4731-adaf-0dcff9afb501", 10, 30, "UTC", ~N[2025-06-26 11:29:12], ~N[2025-06-26 11:29:12]]
     13:29:12.798 [debug] QUERY OK source="event_reminders" db=2.4ms queue=0.5ms
     INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["b7f6a08b-d528-4731-adaf-0dcff9afb501", "test@example.com", ~U[2025-06-26 11:28:12Z], "pending", ~N[2025-06-26 11:29:12], ~N[2025-06-26 11:29:12]]
     13:29:12.799 [debug] QUERY OK source="event_reminders" db=0.6ms
     INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["b7f6a08b-d528-4731-adaf-0dcff9afb501", "test@example.com", ~U[2025-06-26 12:29:12Z], "pending", ~N[2025-06-26 11:29:12], ~N[2025-06-26 11:29:12]]
     13:29:12.856 [debug] MOUNT HydepwnsLiveviewWeb.TestLive.DiagramEditorTestLive
       Parameters: :not_mounted_at_router
       Session: %{"id" => "test-diagram-editor"}
     13:29:12.856 [debug] Replied in 2ms
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "8Yt-NLI3HvPvoDSlPB2rIQQt"}
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "xs5JVkvTyhuHaCvAtPjMJnEq", "id_or_name" => "ID123", "integer_value" => 42, "string_value" => "test string", "tags" => ["tag1", "tag2"], "theme" => "dark", "user" => %{"admin" => true, "id" => "user-id", "name" => "Test User"}}
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "gGlkWs037fanSITyxe3ZeKcy"}
     13:29:12.872 [debug] Replied in 296µs
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "EKKU-mLHkefebInJZdRt1QvG"}
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "hwdFSkki8jx8NvKUAT3lSEHp"}
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "OBjMRvAHhHxx_qCk5Q9LgGtS"}
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "Xe18AFLWPXJ7ooRswI_nVdUz"}
     13:29:12.872 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "k3Wn_K5ViWp_udqU10sv9SLx"}
     13:29:12.872 [debug] Replied in 751µs
     13:29:12.872 [debug] Replied in 677µs
     13:29:12.872 [debug] Replied in 459µs
     13:29:12.872 [debug] Replied in 128µs
     13:29:12.873 [debug] Replied in 501µs
     13:29:12.873 [debug] Replied in 416µs
     13:29:12.873 [debug] Replied in 287µs
     13:29:12.906 [debug] QUERY OK source="event_reminders" db=4.6ms
     SELECT e0."id", e0."reminder_time", e0."status", e0."recipient", e0."sent_at", e0."error_message", e0."event_id", e0."inserted_at", e0."updated_at" FROM "event_reminders" AS e0 WHERE (e0."id" = $1) [329]
     13:29:12.925 [debug] MOUNT HydepwnsLiveviewWeb.TestLive.DiagramEditorTestLive
       Parameters: :not_mounted_at_router
       Session: %{"id" => "test-diagram-editor", "show_template_selector" => false}
     13:29:12.948 [debug] Replied in 22ms
     
..............

  7) test type_validation/3 function emits telemetry events for validation failures (HydepwnsLiveview.TypeValidationTest)
     test/socket_validator/type_validation_test.exs:190
     Assertion failed, no matching message after 100ms
     The process mailbox is empty.
     code: assert_receive {[:hydepwns, :socket_validator, :validation, :type_error], _ref, %{count: 1},
            %{key: :string_value, type_spec: :string, validation_type: :type_validation} = meta}
           when is_map(meta)
     stacktrace:
       test/socket_validator/type_validation_test.exs:209: (test)

     The following output was logged:
     13:29:13.113 [debug] MOUNT HydepwnsLiveviewWeb.TestLive.DiagramEditorTestLive
       Parameters: :not_mounted_at_router
       Session: %{"id" => "test-diagram-editor", "initial_content" => "Custom diagram content"}
     13:29:13.113 [debug] Replied in 141µs
     13:29:13.123 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "OKx1rQWmsB4SHrajcsNSuNEz"}
     13:29:13.123 [debug] Replied in 86µs
     13:29:13.124 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "Qp0rAZrBIfRXfMenVLeWllpJ"}
     13:29:13.124 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "KO1bU11sVKHROp-6F4a_4A-N"}
     13:29:13.124 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "2copVhP9AIYSJLzbd3hr361w"}
     13:29:13.124 [debug] Replied in 290µs
     13:29:13.124 [debug] Replied in 59µs
     13:29:13.124 [debug] Replied in 366µs
     13:29:13.125 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "I9f6bVT6CL_B2v5XNfbeckT1"}
     13:29:13.125 [debug] Replied in 886µs
     13:29:13.127 request_id=GEyUPu0bhZu_2-sAAAHI [info] GET /style-guide
     13:29:13.127 request_id=GEyUPu0bhZu_2-sAAAHI [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.128 request_id=GEyUPu0bhZu_2-sAAAHI [info] Sent 200 in 836µs
     13:29:13.129 [debug] HANDLE EVENT "change_theme" in HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{"theme" => "light"}
     13:29:13.129 [debug] Replied in 55µs
     13:29:13.130 request_id=GEyUPu1S9DLt54AAAAOC [info] GET /style-guide
     13:29:13.131 request_id=GEyUPu1S9DLt54AAAAOC [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.131 request_id=GEyUPu1S9DLt54AAAAOC [info] Sent 200 in 608µs
     13:29:13.167 [debug] MOUNT HydepwnsLiveviewWeb.TestLive.DiagramEditorTestLive
       Parameters: :not_mounted_at_router
       Session: %{"id" => "test-diagram-editor", "show_export" => false}
     13:29:13.167 [debug] Replied in 103µs
     13:29:13.196 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "G6E8ZOi09XLKaIrg2FgKI3HZ"}
     13:29:13.196 [debug] Replied in 403µs
     13:29:13.203 request_id=GEyUPvGguo_0lccAAAPC [info] GET /style-guide
     13:29:13.203 request_id=GEyUPvGguo_0lccAAAPC [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.203 request_id=GEyUPvGguo_0lccAAAPC [info] Sent 200 in 428µs
     13:29:13.205 request_id=GEyUPvHMDbQnTFkAAAII [info] GET /style-guide
     13:29:13.206 request_id=GEyUPvHMDbQnTFkAAAII [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.206 request_id=GEyUPvHMDbQnTFkAAAII [info] Sent 200 in 525µs
     13:29:13.214 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "02vAsyhOhhKfW4kVolzwipDO"}
     13:29:13.214 [debug] Replied in 175µs
     13:29:13.220 request_id=GEyUPvKuxrgEuvIAAAMG [info] GET /style-guide
     13:29:13.221 request_id=GEyUPvKuxrgEuvIAAAMG [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.221 request_id=GEyUPvKuxrgEuvIAAAMG [info] Sent 200 in 856µs
     13:29:13.233 [debug] MOUNT HydepwnsLiveviewWeb.TestLive.DiagramEditorTestLive
       Parameters: :not_mounted_at_router
       Session: %{"id" => "test-diagram-editor", "template" => "flowchart"}
     13:29:13.233 [debug] Replied in 202µs
     13:29:13.238 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "_GMmbXFLmPsUcPg3FeJQqvCt"}
     13:29:13.238 [debug] Replied in 191µs
     13:29:13.248 request_id=GEyUPgwezKf2ksQAAAJj [info] Sent 500 in 3896ms
     13:29:13.249 [debug] MOUNT HydepwnsLiveviewWeb.StyleGuideLive
       Parameters: %{}
       Session: %{"_csrf_token" => "aKKnqFWmBqgM1ukC9u0Tt3Qn"}
     13:29:13.249 [debug] Replied in 607µs
     13:29:13.254 request_id=GEyUPvS37eyvRCUAAAQC [info] GET /style-guide
     13:29:13.254 request_id=GEyUPvS37eyvRCUAAAQC [debug] Processing with HydepwnsLiveviewWeb.StyleGuideLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.255 request_id=GEyUPvS37eyvRCUAAAQC [info] Sent 200 in 443µs
     


  8) test type_validation/3 function validates complex nested structures (HydepwnsLiveview.TypeValidationTest)
     test/socket_validator/type_validation_test.exs:334
     Assertion with =~ failed
     code:  assert message =~ "expected one of"
     left:  "founded: expected integer, got: \"not a number\""
     right: "expected one of"
     stacktrace:
       test/socket_validator/type_validation_test.exs:405: (test)

...

  9) test external API integration displays data from external API when loaded (HydepwnsLiveviewWeb.ExternalAPIIntegrationTest)
     test/hydepwns_liveview_web/live/external_api_integration_test.exs:26
     ** (Mox.UnexpectedCallError) no expectation defined for HydepwnsLiveview.RepoMock.get/3 in process #PID<0.1074.0> with args [HydepwnsLiveview.Resources.Resource, "123", []]
     code: {:ok, view, _html} = live(conn, "/resources/123")
     stacktrace:
       (mox 1.2.0) lib/mox.ex:903: Mox.__dispatch__/4
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview/resources/resource_system.ex:43: HydepwnsLiveview.Resources.ResourceSystem.get_resource/1
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/resources/resource_show_live.ex:13: HydepwnsLiveviewWeb.ResourceShowLive.handle_params/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:456: anonymous fn/5 in Phoenix.LiveView.Utils.call_handle_params!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:322: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/external_api_integration_test.exs:34: (test)

...........

 10) test BaseLive integration with type validation tests boundary conditions with mutations (HydepwnsLiveview.TypeValidationTest)
     test/socket_validator/type_validation_test.exs:501
     Assertion with == failed
     code:  assert assigns[key] == value
     left:  42
     right: 0
     stacktrace:
       test/socket_validator/type_validation_test.exs:531: anonymous fn/3 in HydepwnsLiveview.TypeValidationTest."test BaseLive integration with type validation tests boundary conditions with mutations"/1
       (elixir 1.17.1) lib/enum.ex:2531: Enum."-reduce/3-lists^foldl/2-0-"/3
       test/socket_validator/type_validation_test.exs:512: (test)

     The following output was logged:
     13:29:13.365 request_id=GEyUPvtRw2o814sAAARC [info] GET /test-types
     13:29:13.365 request_id=GEyUPvtRw2o814sAAARC [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.366 request_id=GEyUPvtRw2o814sAAARC [info] Sent 200 in 408µs
     13:29:13.369 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "6V5JCRnc8movKjbIlisOfY1k"}
     13:29:13.369 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "NhBKzeaPtO_-s_fMuyYZxop-"}
     13:29:13.369 [debug] Replied in 81µs
     13:29:13.369 [debug] Replied in 64µs
     13:29:13.372 request_id=GEyUPvu6_9jPMzsAAA1B [info] GET /
     13:29:13.372 request_id=GEyUPvu6_9jPMzsAAA1B [debug] Processing with HydepwnsLiveviewWeb.HomeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.373 request_id=GEyUPvu6_9jPMzsAAA1B [info] Sent 200 in 781µs
     13:29:13.383 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "NksEHcCwQUqE6skjNhoRzZat", "integer_value" => 42, "string_value" => "default", "theme" => "dark"}
     13:29:13.383 [debug] Replied in 92µs
     13:29:13.384 request_id=GEyUPvxwFEo814sAAAij [info] GET /test-types
     13:29:13.384 request_id=GEyUPvxwFEo814sAAAij [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.384 request_id=GEyUPvxwFEo814sAAAij [info] Sent 200 in 333µs
     13:29:13.391 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "Og6qy50nvCBN3DnVeQvhBVCJ"}
     13:29:13.391 [debug] Replied in 186µs
     13:29:13.396 request_id=GEyUPv0nVGZHPGMAAASC [info] GET /
     13:29:13.396 request_id=GEyUPv0nVGZHPGMAAASC [debug] Processing with HydepwnsLiveviewWeb.HomeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.396 request_id=GEyUPv0nVGZHPGMAAASC [info] Sent 200 in 520µs
     13:29:13.405 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "0mzZlxQrs2B7gR6ImXl7I_RI", "integer_value" => "42", "string_value" => "default", "theme" => "dark"}
     13:29:13.405 [debug] Replied in 203µs
     13:29:13.406 request_id=GEyUPv3FNeE814sAAA2B [info] GET /test-types
     13:29:13.406 request_id=GEyUPv3FNeE814sAAA2B [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.407 request_id=GEyUPv3FNeE814sAAA2B [info] Sent 200 in 811µs
     13:29:13.411 [debug] MOUNT HydepwnsLiveviewWeb.HomeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "kh3snvykE6Sc6fEyDp0XgpMn"}
     13:29:13.411 [debug] Replied in 105µs
     13:29:13.423 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "i1p5G0er1t69pR0CQuNddxsF", "integer_value" => 0, "string_value" => "default", "theme" => "dark"}
     13:29:13.423 [debug] Replied in 209µs
     
...

 11) test type_validation/3 function validates nested schemas correctly (HydepwnsLiveview.TypeValidationTest)
     test/socket_validator/type_validation_test.exs:59
     Assertion with =~ failed
     code:  assert message =~ "expected one of"
     left:  "age: expected integer, got: \"thirty\""
     right: "expected one of"
     stacktrace:
       test/socket_validator/type_validation_test.exs:113: (test)

    warning: incompatible types in struct update:

        %Wallaby.Query{query | result: results}

    expected type:

        dynamic(%Wallaby.Query{
          conditions: term(),
          html_validation: term(),
          method: term(),
          result: term(),
          selector: term()
        })

    but got type:

        binary()

    where "query" (context Wallaby.Browser) was given the type:

        # type: binary()
        # from: test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:49
        query = "Resource created successfully"

    where "results" (context Wallaby.Browser) was given the type:

        # type: dynamic()
        # from: test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:49
        results

    typing violation found at:
    │
 49 │       Wallaby.Browser.assert_has(session, "Resource created successfully")
    │       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    │
    └─ test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:49: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest."test resource creation and event generation user can create a resource and see events generated"/1

    warning: incompatible types in struct update:

        %Wallaby.Query{query | result: results}

    expected type:

        dynamic(%Wallaby.Query{
          conditions: term(),
          html_validation: term(),
          method: term(),
          result: term(),
          selector: term()
        })

    but got type:

        binary()

    where "query" (context Wallaby.Browser) was given the type:

        # type: binary()
        # from: test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:72
        query = "Resource updated successfully"

    where "results" (context Wallaby.Browser) was given the type:

        # type: dynamic()
        # from: test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:72
        results

    typing violation found at:
    │
 72 │       Wallaby.Browser.assert_has(session, "Resource updated successfully")
    │       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    │
    └─ test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:72: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest."test resource creation and event generation resource update generates events"/1

    warning: incompatible types in struct update:

        %Wallaby.Query{query | result: results}

    expected type:

        dynamic(%Wallaby.Query{
          conditions: term(),
          html_validation: term(),
          method: term(),
          result: term(),
          selector: term()
        })

    but got type:

        binary()

    where "query" (context Wallaby.Browser) was given the type:

        # type: binary()
        # from: test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:94
        query = "Resource deleted successfully"

    where "results" (context Wallaby.Browser) was given the type:

        # type: dynamic()
        # from: test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:94
        results

    typing violation found at:
    │
 94 │       Wallaby.Browser.assert_has(session, "Resource deleted successfully")
    │       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    │
    └─ test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:94: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest."test resource creation and event generation resource deletion generates events"/1

LOGS: "13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [info] GET /test-types\n13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2\n  Parameters: %{}\n  Pipelines: [:browser]\n13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [info] Sent 200 in 553µs\n13:29:13.444 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive\n  Parameters: %{}\n  Session: %{\"_csrf_token\" => \"BwviKb-64oSX7dtx45P3WLRS\", \"integer_value\" => \"42\", \"string_value\" => 123, \"theme\" => \"invalid\", \"user\" => %{\"admin\" => true, \"id\" => \"user-id\", \"name\" => \"Test User\"}}\n13:29:13.444 [debug] Replied in 297µs\n"


 12) test BaseLive integration with type validation logs validation errors with context information (HydepwnsLiveview.TypeValidationTest)
     test/socket_validator/type_validation_test.exs:472
     Assertion with =~ failed
     code:  assert logs =~ "Type error"
     left:  "13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [info] GET /test-types\n13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2\n  Parameters: %{}\n  Pipelines: [:browser]\n13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [info] Sent 200 in 553µs\n13:29:13.444 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive\n  Parameters: %{}\n  Session: %{\"_csrf_token\" => \"BwviKb-64oSX7dtx45P3WLRS\", \"integer_value\" => \"42\", \"string_value\" => 123, \"theme\" => \"invalid\", \"user\" => %{\"admin\" => true, \"id\" => \"user-id\", \"name\" => \"Test User\"}}\n13:29:13.444 [debug] Replied in 297µs\n"
     right: "Type error"
     stacktrace:
       test/socket_validator/type_validation_test.exs:498: (test)

     The following output was logged:
     13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [info] GET /test-types
     13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [debug] Processing with HydepwnsLiveviewWeb.TestTypeLive.index/2
       Parameters: %{}
       Pipelines: [:browser]
     13:29:13.435 request_id=GEyUPv91PFrGoX8AAASG [info] Sent 200 in 553µs
     13:29:13.444 [debug] MOUNT HydepwnsLiveviewWeb.TestTypeLive
       Parameters: %{}
       Session: %{"_csrf_token" => "BwviKb-64oSX7dtx45P3WLRS", "integer_value" => "42", "string_value" => 123, "theme" => "invalid", "user" => %{"admin" => true, "id" => "user-id", "name" => "Test User"}}
     13:29:13.444 [debug] Replied in 297µs
     
.13:29:13.481 request_id=GEyUPsqyswMPCyIAAAYE [info] Sent 500 in 931ms
13:29:13.482 request_id=GEyUPwJEAWVe7qEAAASm [info] GET /test-resource-live
13:29:13.482 request_id=GEyUPwJEAWVe7qEAAASm [debug] Processing with HydepwnsLiveviewWeb.TestResourceLive.index/2
  Parameters: %{}
  Pipelines: [:browser]


 13) test ResourceLive with assigns_resource mounts with default values (HydepwnsLiveviewWeb.ResourceLiveTest)
     test/hydepwns_liveview_web/live/resource_live_test.exs:7
     ** (FunctionClauseError) no function clause matching in Phoenix.Component.assign/2

     The following arguments were given to Phoenix.Component.assign/2:

         # 1
         #Phoenix.LiveView.Socket<id: "phx-GEyUPswSd0ILIgKH", endpoint: HydepwnsLiveviewWeb.Endpoint, view: HydepwnsLiveviewWeb.TestResourceLive, parent_pid: nil, root_pid: nil, router: HydepwnsLiveviewWeb.Router, assigns: %{__changed__: %{}, flash: %{}, live_action: :index}, transport_pid: nil, sticky?: false, ...>

         # 2
         {:%{}, [], [items: [], page_title: "Test Resource", settings: {:{}, [], [:%{}, [line: 17, column: 43], [theme: "dark"]]}, user: {:{}, [], [:%{}, [line: 11, column: 47], [id: nil, name: "Test User", role: "user"]]}]}

     Attempted function clauses (showing 1 out of 1):

         def assign(socket_or_assigns, keyword_or_map) when -is_map(keyword_or_map)- or -is_list(keyword_or_map)-

     code: {:ok, _view, html} = live(conn, "/test-resource-live")
     stacktrace:
       (phoenix_live_view 1.0.17) lib/phoenix_component.ex:1396: Phoenix.Component.assign/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/test_resource_live.ex:2: HydepwnsLiveviewWeb.TestResourceLive.mount/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:348: anonymous fn/6 in Phoenix.LiveView.Utils.maybe_call_live_view_mount!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:321: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/resource_live_test.exs:8: (test)

13:29:13.536 request_id=GEyUPvsgYx6KT9UAAAhj [info] Sent 500 in 173ms
13:29:13.536 request_id=GEyUPwWFigDI__4AAATm [info] GET /resources/123
13:29:13.536 request_id=GEyUPwWFigDI__4AAATm [debug] Processing with HydepwnsLiveviewWeb.ResourceShowLive.show/2
  Parameters: %{"id" => "123"}
  Pipelines: [:browser]


 14) test external API integration allows user to update resource data (HydepwnsLiveviewWeb.ExternalAPIIntegrationTest)
     test/hydepwns_liveview_web/live/external_api_integration_test.exs:57
     ** (Mox.UnexpectedCallError) no expectation defined for HydepwnsLiveview.RepoMock.get/3 in process #PID<0.1664.0> with args [HydepwnsLiveview.Resources.Resource, "123", []]
     code: {:ok, _view, _html} = live(conn, "/resources/#{resource_id}/edit")
     stacktrace:
       (mox 1.2.0) lib/mox.ex:903: Mox.__dispatch__/4
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview/resources/resource_system.ex:43: HydepwnsLiveview.Resources.ResourceSystem.get_resource/1
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/resources/resource_edit_live.ex:13: HydepwnsLiveviewWeb.ResourceEditLive.handle_params/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:456: anonymous fn/5 in Phoenix.LiveView.Utils.call_handle_params!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:322: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/external_api_integration_test.exs:76: (test)

13:29:13.578 request_id=GEyUPwJEAWVe7qEAAASm [info] Sent 500 in 96ms
13:29:13.579 request_id=GEyUPwgMLeB_aCMAAAGl [info] GET /test-resource-live
13:29:13.579 request_id=GEyUPwgMLeB_aCMAAAGl [debug] Processing with HydepwnsLiveviewWeb.TestResourceLive.index/2
  Parameters: %{}
  Pipelines: [:browser]


 15) test ResourceLive with assigns_resource adds items to list (HydepwnsLiveviewWeb.ResourceLiveTest)
     test/hydepwns_liveview_web/live/resource_live_test.exs:74
     ** (FunctionClauseError) no function clause matching in Phoenix.Component.assign/2

     The following arguments were given to Phoenix.Component.assign/2:

         # 1
         #Phoenix.LiveView.Socket<id: "phx-GEyUPwJHXw3uoQTG", endpoint: HydepwnsLiveviewWeb.Endpoint, view: HydepwnsLiveviewWeb.TestResourceLive, parent_pid: nil, root_pid: nil, router: HydepwnsLiveviewWeb.Router, assigns: %{__changed__: %{}, flash: %{}, live_action: :index}, transport_pid: nil, sticky?: false, ...>

         # 2
         {:%{}, [], [items: [], page_title: "Test Resource", settings: {:{}, [], [:%{}, [line: 17, column: 43], [theme: "dark"]]}, user: {:{}, [], [:%{}, [line: 11, column: 47], [id: nil, name: "Test User", role: "user"]]}]}

     Attempted function clauses (showing 1 out of 1):

         def assign(socket_or_assigns, keyword_or_map) when -is_map(keyword_or_map)- or -is_list(keyword_or_map)-

     code: {:ok, view, _html} = live(conn, "/test-resource-live")
     stacktrace:
       (phoenix_live_view 1.0.17) lib/phoenix_component.ex:1396: Phoenix.Component.assign/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/test_resource_live.ex:2: HydepwnsLiveviewWeb.TestResourceLive.mount/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:348: anonymous fn/6 in Phoenix.LiveView.Utils.maybe_call_live_view_mount!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:321: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/resource_live_test.exs:75: (test)

13:29:13.626 request_id=GEyUPwWFigDI__4AAATm [info] Sent 500 in 89ms


 16) test external API integration handles API errors gracefully (HydepwnsLiveviewWeb.ExternalAPIIntegrationTest)
     test/hydepwns_liveview_web/live/external_api_integration_test.exs:42
     ** (Mox.UnexpectedCallError) no expectation defined for HydepwnsLiveview.RepoMock.get/3 in process #PID<0.1812.0> with args [HydepwnsLiveview.Resources.Resource, "123", []]
     code: {:ok, view, _html} = live(conn, "/resources/123")
     stacktrace:
       (mox 1.2.0) lib/mox.ex:903: Mox.__dispatch__/4
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview/resources/resource_system.ex:43: HydepwnsLiveview.Resources.ResourceSystem.get_resource/1
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/resources/resource_show_live.ex:13: HydepwnsLiveviewWeb.ResourceShowLive.handle_params/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:456: anonymous fn/5 in Phoenix.LiveView.Utils.call_handle_params!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:322: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/external_api_integration_test.exs:49: (test)

13:29:13.669 request_id=GEyUPwgMLeB_aCMAAAGl [info] Sent 500 in 90ms
13:29:13.670 request_id=GEyUPw12irtk9WcAAASi [info] GET /test-resource-live
13:29:13.670 request_id=GEyUPw12irtk9WcAAASi [debug] Processing with HydepwnsLiveviewWeb.TestResourceLive.index/2
  Parameters: %{}
  Pipelines: [:browser]


 17) test ResourceLive with assigns_resource validates resource updates (HydepwnsLiveviewWeb.ResourceLiveTest)
     test/hydepwns_liveview_web/live/resource_live_test.exs:55
     ** (FunctionClauseError) no function clause matching in Phoenix.Component.assign/2

     The following arguments were given to Phoenix.Component.assign/2:

         # 1
         #Phoenix.LiveView.Socket<id: "phx-GEyUPwgQ8R1oIwHF", endpoint: HydepwnsLiveviewWeb.Endpoint, view: HydepwnsLiveviewWeb.TestResourceLive, parent_pid: nil, root_pid: nil, router: HydepwnsLiveviewWeb.Router, assigns: %{__changed__: %{}, flash: %{}, live_action: :index}, transport_pid: nil, sticky?: false, ...>

         # 2
         {:%{}, [], [items: [], page_title: "Test Resource", settings: {:{}, [], [:%{}, [line: 17, column: 43], [theme: "dark"]]}, user: {:{}, [], [:%{}, [line: 11, column: 47], [id: nil, name: "Test User", role: "user"]]}]}

     Attempted function clauses (showing 1 out of 1):

         def assign(socket_or_assigns, keyword_or_map) when -is_map(keyword_or_map)- or -is_list(keyword_or_map)-

     code: {:ok, view, _html} = live(conn, "/test-resource-live")
     stacktrace:
       (phoenix_live_view 1.0.17) lib/phoenix_component.ex:1396: Phoenix.Component.assign/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/test_resource_live.ex:2: HydepwnsLiveviewWeb.TestResourceLive.mount/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:348: anonymous fn/6 in Phoenix.LiveView.Utils.maybe_call_live_view_mount!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:321: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/resource_live_test.exs:56: (test)

13:29:13.711 request_id=GEyUPw12irtk9WcAAASi [info] Sent 500 in 41ms
13:29:13.712 request_id=GEyUPw_2zXjaHusAAATi [info] GET /test-resource-live
13:29:13.712 request_id=GEyUPw_2zXjaHusAAATi [debug] Processing with HydepwnsLiveviewWeb.TestResourceLive.index/2
  Parameters: %{}
  Pipelines: [:browser]


 18) test ResourceLive with assigns_resource updates resource via API (HydepwnsLiveviewWeb.ResourceLiveTest)
     test/hydepwns_liveview_web/live/resource_live_test.exs:36
     ** (FunctionClauseError) no function clause matching in Phoenix.Component.assign/2

     The following arguments were given to Phoenix.Component.assign/2:

         # 1
         #Phoenix.LiveView.Socket<id: "phx-GEyUPw14sin1ZwTC", endpoint: HydepwnsLiveviewWeb.Endpoint, view: HydepwnsLiveviewWeb.TestResourceLive, parent_pid: nil, root_pid: nil, router: HydepwnsLiveviewWeb.Router, assigns: %{__changed__: %{}, flash: %{}, live_action: :index}, transport_pid: nil, sticky?: false, ...>

         # 2
         {:%{}, [], [items: [], page_title: "Test Resource", settings: {:{}, [], [:%{}, [line: 17, column: 43], [theme: "dark"]]}, user: {:{}, [], [:%{}, [line: 11, column: 47], [id: nil, name: "Test User", role: "user"]]}]}

     Attempted function clauses (showing 1 out of 1):

         def assign(socket_or_assigns, keyword_or_map) when -is_map(keyword_or_map)- or -is_list(keyword_or_map)-

     code: {:ok, view, _html} = live(conn, "/test-resource-live")
     stacktrace:
       (phoenix_live_view 1.0.17) lib/phoenix_component.ex:1396: Phoenix.Component.assign/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/test_resource_live.ex:2: HydepwnsLiveviewWeb.TestResourceLive.mount/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:348: anonymous fn/6 in Phoenix.LiveView.Utils.maybe_call_live_view_mount!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:321: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/resource_live_test.exs:37: (test)

13:29:13.750 request_id=GEyUPw_2zXjaHusAAATi [info] Sent 500 in 38ms


 19) test ResourceLive with assigns_resource updates resource values via event (HydepwnsLiveviewWeb.ResourceLiveTest)
     test/hydepwns_liveview_web/live/resource_live_test.exs:20
     ** (FunctionClauseError) no function clause matching in Phoenix.Component.assign/2

     The following arguments were given to Phoenix.Component.assign/2:

         # 1
         #Phoenix.LiveView.Socket<id: "phx-GEyUPw_5vHIe6wUC", endpoint: HydepwnsLiveviewWeb.Endpoint, view: HydepwnsLiveviewWeb.TestResourceLive, parent_pid: nil, root_pid: nil, router: HydepwnsLiveviewWeb.Router, assigns: %{__changed__: %{}, flash: %{}, live_action: :index}, transport_pid: nil, sticky?: false, ...>

         # 2
         {:%{}, [], [items: [], page_title: "Test Resource", settings: {:{}, [], [:%{}, [line: 17, column: 43], [theme: "dark"]]}, user: {:{}, [], [:%{}, [line: 11, column: 47], [id: nil, name: "Test User", role: "user"]]}]}

     Attempted function clauses (showing 1 out of 1):

         def assign(socket_or_assigns, keyword_or_map) when -is_map(keyword_or_map)- or -is_list(keyword_or_map)-

     code: {:ok, view, _html} = live(conn, "/test-resource-live")
     stacktrace:
       (phoenix_live_view 1.0.17) lib/phoenix_component.ex:1396: Phoenix.Component.assign/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/live/test_resource_live.ex:2: HydepwnsLiveviewWeb.TestResourceLive.mount/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/utils.ex:348: anonymous fn/6 in Phoenix.LiveView.Utils.maybe_call_live_view_mount!/5
       (telemetry 1.3.0) /Users/droo/Documents/CODE/Hydepwns/deps/telemetry/src/telemetry.erl:324: :telemetry.span/3
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:321: Phoenix.LiveView.Static.call_mount_and_handle_params!/5
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/static.ex:155: Phoenix.LiveView.Static.do_render/4
       (phoenix_live_view 1.0.17) lib/phoenix_live_view/controller.ex:39: Phoenix.LiveView.Controller.live_render/3
       (phoenix 1.7.21) lib/phoenix/router.ex:484: Phoenix.Router.__call__/5
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.plug_builder_call/2
       (hydepwns_liveview 0.1.0) deps/plug/lib/plug/debugger.ex:155: HydepwnsLiveviewWeb.Endpoint."call (overridable 3)"/2
       (hydepwns_liveview 0.1.0) lib/hydepwns_liveview_web/endpoint.ex:1: HydepwnsLiveviewWeb.Endpoint.call/2
       (phoenix 1.7.21) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/hydepwns_liveview_web/live/resource_live_test.exs:21: (test)

🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1833.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-1
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-1"} => [%{data: %{id: "test-resource-1", value: 0}, resource_id: "test-resource-1", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-1"} => [%{data: %{id: "test-resource-1", value: 0}, resource_id: "test-resource-1", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-1 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1836.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-5
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-5"} => [%{data: %{id: "test-resource-5", value: 10}, resource_id: "test-resource-5", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-5"} => [%{data: %{id: "test-resource-5", value: 10}, resource_id: "test-resource-5", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-5 -> 1 events
🔵 MockEventStore.store_event: reset for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-5
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-5"} => [%{data: %{id: "test-resource-5", value: 10}, resource_id: "test-resource-5", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{}, resource_id: "test-resource-5", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "reset"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-5"} => [%{data: %{id: "test-resource-5", value: 10}, resource_id: "test-resource-5", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{}, resource_id: "test-resource-5", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "reset"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-5 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1839.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4 -> 1 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4 -> 2 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 2, previous_value: 1}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 2, previous_value: 1}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4 -> 3 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 2, previous_value: 1}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 3, previous_value: 3}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 2, previous_value: 1}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 3, previous_value: 3}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4 -> 4 events
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-4"} => [%{data: %{id: "test-resource-4", value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 1, previous_value: 0}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 2, previous_value: 1}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{amount: 3, previous_value: 3}, resource_id: "test-resource-4", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-4 -> 4 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1842.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6 -> 1 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6 -> 2 events
🔵 MockEventStore.store_event: reset for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "reset"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "reset"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6 -> 3 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "reset"}, %{data: %{amount: 7, previous_value: 0}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-6"} => [%{data: %{id: "test-resource-6", value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 5}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "reset"}, %{data: %{amount: 7, previous_value: 0}, resource_id: "test-resource-6", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-6 -> 4 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1845.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-11
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-11"} => [%{data: %{id: "test-resource-11", value: 0}, resource_id: "test-resource-11", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1848.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3 -> 1 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3 -> 2 events
🔵 MockEventStore.store_event: value_set for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{new_value: 10, previous_value: 3}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "value_set"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{new_value: 10, previous_value: 3}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "value_set"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3 -> 3 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{new_value: 10, previous_value: 3}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "value_set"}, %{data: %{amount: 2, previous_value: 10}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-3"} => [%{data: %{id: "test-resource-3", value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 3, previous_value: 0}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}, %{data: %{new_value: 10, previous_value: 3}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "value_set"}, %{data: %{amount: 2, previous_value: 10}, resource_id: "test-resource-3", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-3 -> 4 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1851.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-10
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-10"} => [%{data: %{id: "test-resource-10", value: 0}, resource_id: "test-resource-10", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-10"} => [%{data: %{id: "test-resource-10", value: 0}, resource_id: "test-resource-10", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-10 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1854.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-8
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-8"} => [%{data: %{id: "test-resource-8", value: 0}, resource_id: "test-resource-8", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-9
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-8"} => [%{data: %{id: "test-resource-8", value: 0}, resource_id: "test-resource-8", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}], {HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-9"} => [%{data: %{id: "test-resource-9", value: 0}, resource_id: "test-resource-9", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-8"} => [%{data: %{id: "test-resource-8", value: 0}, resource_id: "test-resource-8", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}], {HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-9"} => [%{data: %{id: "test-resource-9", value: 0}, resource_id: "test-resource-9", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-8 -> 1 events
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-8"} => [%{data: %{id: "test-resource-8", value: 0}, resource_id: "test-resource-8", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}], {HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-9"} => [%{data: %{id: "test-resource-9", value: 0}, resource_id: "test-resource-9", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-9 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1857.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-2"} => [%{data: %{id: "test-resource-2", value: 0}, resource_id: "test-resource-2", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-2"} => [%{data: %{id: "test-resource-2", value: 0}, resource_id: "test-resource-2", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-2 -> 1 events
🔵 MockEventStore.store_event: incremented for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-2"} => [%{data: %{id: "test-resource-2", value: 0}, resource_id: "test-resource-2", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 5, previous_value: 0}, resource_id: "test-resource-2", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-2"} => [%{data: %{id: "test-resource-2", value: 0}, resource_id: "test-resource-2", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}, %{data: %{amount: 5, previous_value: 0}, resource_id: "test-resource-2", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "incremented"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-2 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1860.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: resource.created for Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-7
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-7"} => [%{data: %{id: "test-resource-7", value: 0}, resource_id: "test-resource-7", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, "test-resource-7"} => [%{data: %{id: "test-resource-7", value: 0}, resource_id: "test-resource-7", resource_type: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource, type: "resource.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest.TestResource:test-resource-7 -> 1 events
.13:29:13.768 [debug] QUERY OK source="versioned_states" db=1.9ms queue=1.1ms
INSERT INTO "versioned_states" ("created_at","label","metadata","resource_id","resource_type","state","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [~U[2025-06-26 11:29:13.763946Z], "test_version", %{}, "123", "test_resource", %{value: 42}, "78c11576-5758-40bd-9531-a2f548bac3b6"]
.13:29:13.770 [debug] QUERY OK source="resource_snapshots" db=0.9ms queue=0.7ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{event_id: "123", version: 1}, "123", "test_resource", %{value: 42}, ~U[2025-06-26 11:29:13.769063Z], ~U[2025-06-26 11:29:13.769063Z], "2c2286d3-673c-4c0a-a3ef-37bee7e07b38"]
.13:29:13.772 [debug] QUERY OK source="resource_snapshots" db=0.5ms queue=0.7ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 1}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.771194Z], ~U[2025-06-26 11:29:13.771194Z], "046719f2-1733-4d76-9638-bf9b96a2e66e"]
13:29:13.772 [debug] QUERY OK source="resource_snapshots" db=0.1ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 2}, "123", "test_resource", %{value: 2}, ~U[2025-06-26 11:29:13.772680Z], ~U[2025-06-26 11:29:13.772680Z], "cc4678ca-10ab-40fd-ae0c-ac039632e42d"]
13:29:13.773 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 3}, "123", "test_resource", %{value: 3}, ~U[2025-06-26 11:29:13.772966Z], ~U[2025-06-26 11:29:13.772966Z], "a056df31-f276-4d95-b83b-af7a78867f7f"]
13:29:13.778 [debug] QUERY OK source="resource_snapshots" db=0.9ms queue=0.9ms
SELECT r0."id", r0."resource_type", r0."resource_id", r0."state", r0."metadata", r0."inserted_at", r0."updated_at" FROM "resource_snapshots" AS r0 WHERE (r0."resource_type" = $1) AND (r0."resource_id" = $2) ORDER BY r0."inserted_at" DESC LIMIT 1 ["test_resource", "nonexistent"]
.13:29:13.780 [debug] QUERY OK source="resource_snapshots" db=0.6ms queue=1.0ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 1}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.778949Z], ~U[2025-06-26 11:29:13.778949Z], "67164e76-8ba4-41bf-a838-f33d2b380ac0"]
13:29:13.781 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 2}, "123", "test_resource", %{value: 2}, ~U[2025-06-26 11:29:13.780901Z], ~U[2025-06-26 11:29:13.780901Z], "92f880df-6cc9-4fe3-b2f7-709cab548a6c"]
13:29:13.781 [debug] QUERY OK source="resource_snapshots" db=0.1ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 3}, "123", "test_resource", %{value: 3}, ~U[2025-06-26 11:29:13.781358Z], ~U[2025-06-26 11:29:13.781358Z], "40186f27-82f8-4cf8-884f-a982c3c7c795"]
13:29:13.783 [debug] QUERY OK source="resource_snapshots" db=1.5ms
SELECT r0."id", r0."resource_type", r0."resource_id", r0."state", r0."metadata", r0."inserted_at", r0."updated_at" FROM "resource_snapshots" AS r0 WHERE (r0."resource_type" = $1) AND (r0."resource_id" = $2) ORDER BY r0."inserted_at" DESC LIMIT 1 ["test_resource", "123"]
.13:29:13.785 [debug] QUERY OK source="resource_snapshots" db=0.5ms queue=0.8ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 1}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.783926Z], ~U[2025-06-26 11:29:13.783926Z], "e66195d5-4ca5-4ec2-befb-8b5efdc135d7"]
13:29:13.785 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 2}, "123", "test_resource", %{value: 2}, ~U[2025-06-26 11:29:13.785527Z], ~U[2025-06-26 11:29:13.785527Z], "c6678f6d-9a70-4f12-a7b6-634f4e965376"]
13:29:13.786 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 3}, "123", "test_resource", %{value: 3}, ~U[2025-06-26 11:29:13.785874Z], ~U[2025-06-26 11:29:13.785874Z], "0ed2fbe2-f46e-463e-91a1-7e4e92c81417"]
.13:29:13.787 [debug] QUERY OK source="versioned_states" db=0.4ms queue=0.2ms
INSERT INTO "versioned_states" ("created_at","label","metadata","point_in_time","replay_id","resource_id","resource_type","state","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [~U[2025-06-26 11:29:13.786451Z], "test_version", %{version: 1}, ~U[2025-06-26 11:29:13.786453Z], "c6ff5a40-ce27-4644-85ce-0f85d9a975b7", "123", "test_resource", %{value: 42}, "be09cb24-048d-441b-bbb0-9f4dd1f31009"]
.13:29:13.788 [debug] QUERY OK source="resource_snapshots" db=0.4ms queue=0.6ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 1}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.787455Z], ~U[2025-06-26 11:29:13.787455Z], "6fd5ce44-8d16-4e10-a656-02e85183c277"]
13:29:13.789 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 2}, "123", "test_resource", %{value: 2}, ~U[2025-06-26 11:29:13.788734Z], ~U[2025-06-26 11:29:13.788734Z], "d60fe5e7-e34d-4bc1-81d5-83998d210570"]
13:29:13.789 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 3}, "123", "test_resource", %{value: 3}, ~U[2025-06-26 11:29:13.789093Z], ~U[2025-06-26 11:29:13.789093Z], "9c0806f4-7896-4108-9d09-44f85835e50b"]
..13:29:13.791 [debug] QUERY OK source="resource_snapshots" db=0.5ms queue=0.7ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 1}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.790148Z], ~U[2025-06-26 11:29:13.790148Z], "3f219586-283f-487b-bfae-fa8fb4958041"]
13:29:13.791 [debug] QUERY OK source="resource_snapshots" db=0.1ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 2}, "123", "test_resource", %{value: 2}, ~U[2025-06-26 11:29:13.791568Z], ~U[2025-06-26 11:29:13.791568Z], "205fcc10-2dd4-4c8f-93a6-8b09e0f9e662"]
13:29:13.792 [debug] QUERY OK source="resource_snapshots" db=0.1ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 3}, "123", "test_resource", %{value: 3}, ~U[2025-06-26 11:29:13.791898Z], ~U[2025-06-26 11:29:13.791898Z], "41730348-20cc-4a5b-a2d5-fcc37beb9834"]
13:29:13.793 [debug] QUERY OK source="resource_snapshots" db=0.5ms queue=0.7ms
SELECT r0."id", r0."resource_type", r0."resource_id", r0."state", r0."metadata", r0."inserted_at", r0."updated_at" FROM "resource_snapshots" AS r0 WHERE ((r0."resource_type" = $1) AND (r0."resource_id" = $2)) ORDER BY r0."inserted_at" ["test_resource", "nonexistent"]
..13:29:13.795 [debug] QUERY OK source="resource_snapshots" db=0.6ms queue=0.7ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{event_id: "event1"}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.793923Z], ~U[2025-06-26 11:29:13.793923Z], "7ef34be8-eb32-41bf-8cd8-ee747699475f"]
13:29:13.796 [debug] QUERY OK source="events" db=0.6ms queue=0.4ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:13.795370Z], "test_event", ~U[2025-06-26 11:29:13.795388Z], ~U[2025-06-26 11:29:13.795388Z], "f0e5dae8-f093-4bd5-ab55-94d9f53e311f"]
13:29:13.796 [debug] QUERY OK source="events" db=0.2ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:13.796577Z], "test_event", ~U[2025-06-26 11:29:13.796594Z], ~U[2025-06-26 11:29:13.796594Z], "5fc3b9d9-7f00-47f6-8438-77449b1d9b72"]
.13:29:13.798 [debug] QUERY OK source="resource_snapshots" db=0.5ms queue=0.8ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{event_id: "event1"}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.797246Z], ~U[2025-06-26 11:29:13.797246Z], "d4d73c6b-991d-4d91-8881-adc738614646"]
13:29:13.799 [debug] QUERY OK source="events" db=0.4ms queue=0.3ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:13.798771Z], "test_event", ~U[2025-06-26 11:29:13.798787Z], ~U[2025-06-26 11:29:13.798787Z], "32faf091-f262-4ca6-860d-ed57193db354"]
13:29:13.800 [debug] QUERY OK source="events" db=0.2ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:13.799697Z], "test_event", ~U[2025-06-26 11:29:13.799711Z], ~U[2025-06-26 11:29:13.799711Z], "897fea2b-8216-480c-bf80-acb64014bd2f"]
13:29:13.800 [debug] QUERY OK source="events" db=0.1ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "nonexistent", "test_resource", ~U[2025-06-26 11:29:13.800048Z], "test_event", ~U[2025-06-26 11:29:13.800061Z], ~U[2025-06-26 11:29:13.800061Z], "dc00bfce-b1b8-4899-97ad-35e3fb5d1494"]
13:29:13.800 [debug] QUERY OK source="events" db=0.1ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "nonexistent", "test_resource", ~U[2025-06-26 11:29:13.800363Z], "test_event", ~U[2025-06-26 11:29:13.800376Z], ~U[2025-06-26 11:29:13.800376Z], "6eacaa39-19b3-4a11-89c7-ea0ed2679017"]
13:29:13.802 [debug] QUERY OK source="resource_snapshots" db=1.3ms
SELECT r0."id", r0."resource_type", r0."resource_id", r0."state", r0."metadata", r0."inserted_at", r0."updated_at" FROM "resource_snapshots" AS r0 WHERE (r0."resource_type" = $1) AND (r0."resource_id" = $2) ORDER BY r0."inserted_at" DESC LIMIT 1 ["test_resource", "nonexistent"]
.13:29:13.803 [debug] QUERY OK source="events" db=0.7ms queue=0.5ms
SELECT count(*) FROM "events" AS e0 WHERE ((e0."resource_type" = $1) AND (e0."resource_id" = $2)) ["test_resource", "nonexistent"]
13:29:13.805 [debug] QUERY OK source="resource_snapshots" db=0.4ms queue=0.7ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{}, "123", "test_resource", %{value: 42}, ~U[2025-06-26 11:29:13.803776Z], ~U[2025-06-26 11:29:13.803776Z], "8142a44f-121c-4ab8-ba8f-360a98d43dd5"]
.13:29:13.806 [debug] QUERY OK source="resource_snapshots" db=0.4ms queue=0.6ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 1}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.805306Z], ~U[2025-06-26 11:29:13.805306Z], "35ffa9bb-b148-49b4-b702-cafbef8ba8c6"]
13:29:13.806 [debug] QUERY OK source="resource_snapshots" db=0.2ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 2}, "123", "test_resource", %{value: 2}, ~U[2025-06-26 11:29:13.806534Z], ~U[2025-06-26 11:29:13.806534Z], "03dfb447-41b8-4437-9dd1-3babe8c661e1"]
13:29:13.807 [debug] QUERY OK source="resource_snapshots" db=0.1ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{version: 3}, "123", "test_resource", %{value: 3}, ~U[2025-06-26 11:29:13.806857Z], ~U[2025-06-26 11:29:13.806857Z], "78994c31-a457-414a-b9f5-0e38a3667b64"]
13:29:13.808 [debug] QUERY OK source="resource_snapshots" db=1.3ms
SELECT r0."id", r0."resource_type", r0."resource_id", r0."state", r0."metadata", r0."inserted_at", r0."updated_at" FROM "resource_snapshots" AS r0 WHERE ((r0."resource_type" = $1) AND (r0."resource_id" = $2)) ORDER BY r0."inserted_at" ["test_resource", "123"]
.13:29:13.810 [debug] QUERY OK source="resource_snapshots" db=0.5ms queue=0.7ms
INSERT INTO "resource_snapshots" ("metadata","resource_id","resource_type","state","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7) [%{event_id: "event1"}, "123", "test_resource", %{value: 1}, ~U[2025-06-26 11:29:13.808816Z], ~U[2025-06-26 11:29:13.808816Z], "b55a2ec8-9e63-4949-b774-cc9d2e524691"]
13:29:13.810 [debug] QUERY OK source="events" db=0.3ms queue=0.2ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:13.810168Z], "test_event", ~U[2025-06-26 11:29:13.810183Z], ~U[2025-06-26 11:29:13.810183Z], "978da977-36e9-4810-8a70-1f4c38fbcb9d"]
13:29:13.811 [debug] QUERY OK source="events" db=0.2ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:13.810887Z], "test_event", ~U[2025-06-26 11:29:13.810902Z], ~U[2025-06-26 11:29:13.810902Z], "cad93663-737d-4bfd-a346-7aaff9c2e87a"]
13:29:13.812 [debug] QUERY OK source="resource_snapshots" db=1.1ms
SELECT r0."id", r0."resource_type", r0."resource_id", r0."state", r0."metadata", r0."inserted_at", r0."updated_at" FROM "resource_snapshots" AS r0 WHERE (r0."resource_type" = $1) AND (r0."resource_id" = $2) ORDER BY r0."inserted_at" DESC LIMIT 1 ["test_resource", "123"]
13:29:13.813 [debug] QUERY OK source="events" db=0.6ms
SELECT count(*) FROM "events" AS e0 WHERE ((e0."resource_type" = $1) AND (e0."resource_id" = $2)) ["test_resource", "123"]
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1897.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-1
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-1"} => [%{data: %{active: true, email: "test@example.com", id: "test-user-1", last_login: nil, name: "Test User", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-1", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-1"} => [%{data: %{active: true, email: "test@example.com", id: "test-user-1", last_login: nil, name: "Test User", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-1", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-1 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1900.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-4"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-4", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-4"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-4", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-4 -> 1 events
🔵 MockEventStore.store_event: user.updated for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-4"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-4", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{name: "Updated Name"}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.updated"}]}
🔵 MockEventStore.store_event: user.deleted for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-4"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-4", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{name: "Updated Name"}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.updated"}, %{data: %{}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-4"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-4", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{name: "Updated Name"}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.updated"}, %{data: %{}, resource_id: "test-user-4", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-4 -> 3 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1903.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-3"} => [%{data: %{active: true, email: "delete@example.com", id: "test-user-3", last_login: nil, name: "To Delete", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-3", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🔵 MockEventStore.store_event: user.deleted for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-3"} => [%{data: %{active: true, email: "delete@example.com", id: "test-user-3", last_login: nil, name: "To Delete", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-3", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{}, resource_id: "test-user-3", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-3"} => [%{data: %{active: true, email: "delete@example.com", id: "test-user-3", last_login: nil, name: "To Delete", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-3", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{}, resource_id: "test-user-3", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-3 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.1906.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-2"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-2", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-2", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-2"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-2", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-2", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-2 -> 1 events
🔵 MockEventStore.store_event: user.updated for Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-2"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-2", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-2", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{email: "updated@example.com", name: "Updated Name"}, resource_id: "test-user-2", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.updated"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestUserResource, "test-user-2"} => [%{data: %{active: true, email: "original@example.com", id: "test-user-2", last_login: nil, name: "Original Name", permissions: [], role: "viewer", settings: %{notifications: true, sidebar_collapsed: false, theme: "system"}, team_id: nil}, resource_id: "test-user-2", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.created"}, %{data: %{email: "updated@example.com", name: "Updated Name"}, resource_id: "test-user-2", resource_type: HydepwnsLiveview.Resources.TestUserResource, type: "user.updated"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestUserResource:test-user-2 -> 2 events
.

 20) test bridge module consistency bridge modules delegate to corresponding core functions (HydepwnsLiveview.Events.BridgeConsistencyTest)
     test/hydepwns_liveview/events/bridge_consistency_test.exs:17
     Bridge function HydepwnsLiveview.Events.EventStore.delete_snapshot/1 does not have a matching core implementation
     code: for {bridge_module, core_module} <- @bridge_mappings do
     stacktrace:
       test/hydepwns_liveview/events/bridge_consistency_test.exs:27: anonymous fn/4 in HydepwnsLiveview.Events.BridgeConsistencyTest."test bridge module consistency bridge modules delegate to corresponding core functions"/1
       (elixir 1.17.1) lib/enum.ex:2531: Enum."-reduce/3-lists^foldl/2-0-"/3
       test/hydepwns_liveview/events/bridge_consistency_test.exs:25: anonymous fn/2 in HydepwnsLiveview.Events.BridgeConsistencyTest."test bridge module consistency bridge modules delegate to corresponding core functions"/1
       (elixir 1.17.1) lib/enum.ex:2531: Enum."-reduce/3-lists^foldl/2-0-"/3
       test/hydepwns_liveview/events/bridge_consistency_test.exs:18: (test)

13:29:16.272 request_id=GEyUP6iRX0yVAKgAAA2h [info] GET /themes
13:29:16.272 request_id=GEyUP6iRX0yVAKgAAA2h [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:16.274 request_id=GEyUP6iRX0yVAKgAAA2h [info] Sent 200 in 2ms


 21) test resource event processing and subscription events are generated and processed during resource updates (HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:39
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:23: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit__/2

13:29:17.418 request_id=GEyUP-zpxzao83gAAA3B [info] GET /themes
13:29:17.419 request_id=GEyUP-zpxzao83gAAA3B [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:17.419 request_id=GEyUP-zpxzao83gAAA3B [info] Sent 200 in 323µs


 22) test resource event processing and subscription event processing error handling (HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:186
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:23: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit__/2

13:29:18.503 request_id=GEyUQC2RT5jZ1wUAAA3h [info] GET /themes
13:29:18.503 request_id=GEyUQC2RT5jZ1wUAAA3h [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:18.504 request_id=GEyUQC2RT5jZ1wUAAA3h [info] Sent 200 in 778µs


 23) test resource event processing and subscription event subscription management (HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:145
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:23: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit__/2

13:29:19.685 request_id=GEyUQHQFgjLE8ioAAA4B [info] GET /themes
13:29:19.686 request_id=GEyUQHQFgjLE8ioAAA4B [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:19.687 request_id=GEyUQHQFgjLE8ioAAA4B [info] Sent 200 in 1ms


 24) test resource event processing and subscription event visualization shows processing status (HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:118
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:23: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit__/2

13:29:21.023 request_id=GEyUQMPBv7qV_McAAA4h [info] GET /themes
13:29:21.024 request_id=GEyUQMPBv7qV_McAAA4h [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:21.025 request_id=GEyUQMPBv7qV_McAAA4h [info] Sent 200 in 1ms


 25) test resource event processing and subscription event processing maintains consistency (HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:80
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:23: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest.__ex_unit__/2



 26) test theme performance _theme switching is smooth (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:368
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 27) test theme management and application _theme can be created and applied (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:83
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 28) test theme customization theme typography can be customized (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:210
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 29) test theme customization theme colors can be customized (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:181
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 30) test theme customization theme spacing can be customized (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:232
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 31) test theme performance theme changes are applied efficiently (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:342
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 32) test theme accessibility theme maintains accessibility standards (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:402
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 33) test theme management and application theme can be deleted (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:152
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 34) test theme persistence and synchronization theme changes persist across sessions (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:309
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 35) test theme persistence and synchronization theme changes sync across components (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:282
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2

🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2040.0>}
🟣 MockEventStore.reset called


 36) test theme management and application _theme can be edited and updated (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:112
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 37) test theme accessibility _theme supports reduced motion (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:422
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2



 38) test theme persistence and synchronization theme preferences are persisted (HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest)
     test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:253
     ** (MatchError) no match of right hand side value: {:error, {{:badmatch, :already_shared}, [{Ecto.Adapters.SQL.Sandbox, :"-start_owner!/2-fun-0-", 3, [file: ~c"lib/ecto/adapters/sql/sandbox.ex", line: 449]}, {Agent.Server, :init, 1, [file: ~c"lib/agent/server.ex", line: 8]}, {:gen_server, :init_it, 2, [file: ~c"gen_server.erl", line: 851]}, {:gen_server, :init_it, 6, [file: ~c"gen_server.erl", line: 814]}, {:proc_lib, :init_p_do_apply, 3, [file: ~c"proc_lib.erl", line: 240]}]}}
     stacktrace:
       (ecto_sql 3.12.1) lib/ecto/adapters/sql/sandbox.ex:443: Ecto.Adapters.SQL.Sandbox.start_owner!/2
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:27: HydepwnsLiveviewWeb.WallabyCase.__ex_unit_setup_0/1
       (hydepwns_liveview 0.1.0) test/support/wallaby_case.ex:1: HydepwnsLiveviewWeb.WallabyCase.__ex_unit__/2
       test/hydepwns_liveview_web/features/theme_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest.__ex_unit__/2

🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-1
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-1"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.882898Z], email: "test@example.com", id: "test-example-user-1", metadata: %{role: "viewer"}, name: "Test User", status: "active", updated_at: ~U[2025-06-26 11:29:21.882905Z]}, resource_id: "test-example-user-1", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-1"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.882898Z], email: "test@example.com", id: "test-example-user-1", metadata: %{role: "viewer"}, name: "Test User", status: "active", updated_at: ~U[2025-06-26 11:29:21.882905Z]}, resource_id: "test-example-user-1", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-1 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2043.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-4"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.891865Z], email: "original@example.com", id: "test-example-user-4", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.891878Z]}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-4"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.891865Z], email: "original@example.com", id: "test-example-user-4", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.891878Z]}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-4 -> 1 events
🔵 MockEventStore.store_event: user.updated for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-4"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.891865Z], email: "original@example.com", id: "test-example-user-4", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.891878Z]}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{name: "Updated Name"}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.updated"}]}
🔵 MockEventStore.store_event: user.deleted for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-4"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.891865Z], email: "original@example.com", id: "test-example-user-4", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.891878Z]}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{name: "Updated Name"}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.updated"}, %{data: %{}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-4"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.891865Z], email: "original@example.com", id: "test-example-user-4", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.891878Z]}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{name: "Updated Name"}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.updated"}, %{data: %{}, resource_id: "test-example-user-4", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-4 -> 3 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2046.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-3"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.894083Z], email: "delete@example.com", id: "test-example-user-3", metadata: %{}, name: "To Delete", status: "active", updated_at: ~U[2025-06-26 11:29:21.894094Z]}, resource_id: "test-example-user-3", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🔵 MockEventStore.store_event: user.deleted for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-3"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.894083Z], email: "delete@example.com", id: "test-example-user-3", metadata: %{}, name: "To Delete", status: "active", updated_at: ~U[2025-06-26 11:29:21.894094Z]}, resource_id: "test-example-user-3", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{}, resource_id: "test-example-user-3", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-3"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.894083Z], email: "delete@example.com", id: "test-example-user-3", metadata: %{}, name: "To Delete", status: "active", updated_at: ~U[2025-06-26 11:29:21.894094Z]}, resource_id: "test-example-user-3", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{}, resource_id: "test-example-user-3", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-3 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2049.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: user.created for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-2"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.898310Z], email: "original@example.com", id: "test-example-user-2", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.898319Z]}, resource_id: "test-example-user-2", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-2"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.898310Z], email: "original@example.com", id: "test-example-user-2", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.898319Z]}, resource_id: "test-example-user-2", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-2 -> 1 events
🔵 MockEventStore.store_event: user.updated for Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-2"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.898310Z], email: "original@example.com", id: "test-example-user-2", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.898319Z]}, resource_id: "test-example-user-2", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{email: "updated@example.com", name: "Updated Name"}, resource_id: "test-example-user-2", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.updated"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestExampleUserResource, "test-example-user-2"} => [%{data: %{created_at: ~U[2025-06-26 11:29:21.898310Z], email: "original@example.com", id: "test-example-user-2", metadata: %{}, name: "Original Name", status: "active", updated_at: ~U[2025-06-26 11:29:21.898319Z]}, resource_id: "test-example-user-2", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.created"}, %{data: %{email: "updated@example.com", name: "Updated Name"}, resource_id: "test-example-user-2", resource_type: HydepwnsLiveview.Resources.TestExampleUserResource, type: "user.updated"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestExampleUserResource:test-example-user-2 -> 2 events
.13:29:22.710 request_id=GEyUQShVkPhRc1YAAA5B [info] GET /themes
13:29:22.711 request_id=GEyUQShVkPhRc1YAAA5B [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:22.712 request_id=GEyUQShVkPhRc1YAAA5B [info] Sent 200 in 1ms


 39) test resource creation and event generation user can create a resource and see events generated (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:36
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

13:29:24.259 request_id=GEyUQYSm10yT7VsAAAIF [info] GET /themes
13:29:24.260 request_id=GEyUQYSm10yT7VsAAAIF [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:24.260 request_id=GEyUQYSm10yT7VsAAAIF [info] Sent 200 in 1ms


 40) test event visualization and monitoring user can filter events (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:128
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

13:29:25.389 request_id=GEyUQcf21cJT6WgAAAIl [info] GET /themes
13:29:25.389 request_id=GEyUQcf21cJT6WgAAAIl [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:25.390 request_id=GEyUQcf21cJT6WgAAAIl [info] Sent 200 in 1ms


 41) test event visualization and monitoring user can view event timeline (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:107
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

13:29:26.543 request_id=GEyUQgzAURrv9OoAAAJF [info] GET /themes
13:29:26.543 request_id=GEyUQgzAURrv9OoAAAJF [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:26.543 request_id=GEyUQgzAURrv9OoAAAJF [info] Sent 200 in 483µs


 42) test event subscription and notifications user can subscribe to event notifications (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:156
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

13:29:27.622 request_id=GEyUQk0Z33mUNAkAAAVG [info] GET /themes
13:29:27.629 request_id=GEyUQk0Z33mUNAkAAAVG [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:27.630 request_id=GEyUQk0Z33mUNAkAAAVG [info] Sent 200 in 7ms


 43) test resource creation and event generation resource deletion generates events (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:83
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

13:29:28.788 request_id=GEyUQpKU9cbO8pMAAAVm [info] GET /themes
13:29:28.790 request_id=GEyUQpKU9cbO8pMAAAVm [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:28.791 request_id=GEyUQpKU9cbO8pMAAAVm [info] Sent 200 in 3ms


 44) test resource creation and event generation resource update generates events (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:60
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

13:29:29.959 request_id=GEyUQthldkpkp4IAAAjj [info] GET /themes
13:29:29.960 request_id=GEyUQthldkpkp4IAAAjj [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:29.960 request_id=GEyUQthldkpkp4IAAAjj [info] Sent 200 in 1ms


 45) test event-driven UI updates UI updates in real-time when events occur (HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest)
     test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:186
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Test Resource", status: "active", type: "document"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:20: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_event_system_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest.__ex_unit__/2

..............

 46) test theme fixtures theme names are unique (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:135
     match (=) failed
     code:  assert {:error, changeset} = theme_fixture(%{name: "test-theme"})
     left:  {:error, changeset}
     right: {:ok,
             %HydepwnsLiveview.ThemeSystem.Models.Theme{
               __meta__: #Ecto.Schema.Metadata<:built, "themes">,
               id: 3,
               name: "test-theme",
               mode: "light",
               primary_color: "#3B82F6",
               secondary_color: "#10B981",
               background_color: "#FFFFFF",
               text_color: "#1F2937",
               is_default: false,
               __unset_other_defaults__: nil,
               colors: %{},
               settings: %{
                 animations: true,
                 contrast: "normal",
                 font_size: "medium",
                 line_height: "normal"
               },
               inserted_at: ~U[2025-06-26 11:29:30.611607Z],
               updated_at: ~U[2025-06-26 11:29:30.611608Z]
             }}
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:137: (test)



 47) test theme fixtures theme_fixture/1 creates a basic theme with default values (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:8
     Assertion with =~ failed
     code:  assert theme.name =~ ~r"test-theme--\d+"
     left:  "Test Theme"
     right: ~r/test-theme--\d+/
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:11: (test)



 48) test theme fixtures system_theme_fixture/1 creates a system theme with system values (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:55
     Assertion with == failed
     code:  assert theme.colors[:background] == "system"
     left:  nil
     right: "system"
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:60: (test)



 49) test theme fixtures dark_theme_fixture/1 creates a dark theme with correct defaults (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:44
     Assertion with == failed
     code:  assert theme.name == "dark"
     left:  "Dark Theme"
     right: "dark"
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:47: (test)



 50) test theme fixtures dim_theme_fixture/1 creates a dim theme with correct defaults (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:65
     Assertion with == failed
     code:  assert theme.colors[:background] == "#1f2937"
     left:  nil
     right: "#1f2937"
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:70: (test)

.

 51) test theme fixture interactions setting a theme as default unsets other defaults (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:172
     Assertion with == failed
     code:  assert ThemeSystem.get_default_theme().id == light_theme.id
     left:  1
     right: 2
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:177: (test)

..

 52) test theme fixtures light_theme_fixture/1 creates a light theme with correct defaults (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:34
     Assertion with == failed
     code:  assert theme.name == "light"
     left:  "Light Theme"
     right: "light"
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:37: (test)



 53) test theme fixtures custom_theme_fixture/1 creates a theme with custom settings (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:97
     Assertion with =~ failed
     code:  assert theme.name =~ ~r"custom--\d+"
     left:  "Custom Theme"
     right: ~r/custom--\d+/
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:100: (test)

..

 54) test theme fixtures theme colors are properly structured (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:146
     Expected truthy, got false
     code: assert Map.has_key?(theme.colors, :primary)
     arguments:

         # 1
         %{}

         # 2
         :primary

     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:149: (test)



 55) test theme fixtures high_contrast_theme_fixture/1 creates an accessible theme (HydepwnsLiveview.ThemeSystem.FixturesTest)
     test/hydepwns_liveview/theme_system/fixtures_test.exs:75
     Assertion with == failed
     code:  assert theme.colors[:background] == "#000000"
     left:  nil
     right: "#000000"
     stacktrace:
       test/hydepwns_liveview/theme_system/fixtures_test.exs:80: (test)

.

 56) test themes list_themes/0 returns all themes (HydepwnsLiveview.ThemeSystemTest)
     test/hydepwns_liveview/theme_system_test.exs:30
     Assertion with == failed
     code:  assert length(themes) == 1
     left:  2
     right: 1
     stacktrace:
       test/hydepwns_liveview/theme_system_test.exs:33: (test)

...........🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2203.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: team.created for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-1
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-1"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.628348Z], description: "A test team", id: "test-team-1", name: "Test Team"}, resource_id: "test-team-1", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-1"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.628348Z], description: "A test team", id: "test-team-1", name: "Test Team"}, resource_id: "test-team-1", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-1 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2206.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: team.created for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-4"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.629748Z], description: "Original description", id: "test-team-4", name: "Original Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-4"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.629748Z], description: "Original description", id: "test-team-4", name: "Original Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-4 -> 1 events
🔵 MockEventStore.store_event: team.updated for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-4"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.629748Z], description: "Original description", id: "test-team-4", name: "Original Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{name: "Updated Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.updated"}]}
🔵 MockEventStore.store_event: team.deleted for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-4"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.629748Z], description: "Original description", id: "test-team-4", name: "Original Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{name: "Updated Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.updated"}, %{data: %{}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-4"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.629748Z], description: "Original description", id: "test-team-4", name: "Original Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{name: "Updated Team"}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.updated"}, %{data: %{}, resource_id: "test-team-4", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-4 -> 3 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2209.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: team.created for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-3"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630368Z], description: "Will be deleted", id: "test-team-3", name: "To Delete"}, resource_id: "test-team-3", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🔵 MockEventStore.store_event: team.deleted for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-3"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630368Z], description: "Will be deleted", id: "test-team-3", name: "To Delete"}, resource_id: "test-team-3", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{}, resource_id: "test-team-3", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-3"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630368Z], description: "Will be deleted", id: "test-team-3", name: "To Delete"}, resource_id: "test-team-3", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{}, resource_id: "test-team-3", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-3 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2212.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: team.created for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-2"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630788Z], description: "Original description", id: "test-team-2", name: "Original Team"}, resource_id: "test-team-2", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-2"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630788Z], description: "Original description", id: "test-team-2", name: "Original Team"}, resource_id: "test-team-2", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-2 -> 1 events
🔵 MockEventStore.store_event: team.updated for Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-2"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630788Z], description: "Original description", id: "test-team-2", name: "Original Team"}, resource_id: "test-team-2", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{description: "Updated description", name: "Updated Team"}, resource_id: "test-team-2", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.updated"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestTeamResource, "test-team-2"} => [%{data: %{active: true, created_at: ~U[2025-06-26 11:29:30.630788Z], description: "Original description", id: "test-team-2", name: "Original Team"}, resource_id: "test-team-2", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.created"}, %{data: %{description: "Updated description", name: "Updated Team"}, resource_id: "test-team-2", resource_type: HydepwnsLiveview.Resources.TestTeamResource, type: "team.updated"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestTeamResource:test-team-2 -> 2 events
.13:29:30.631 request_id=GEyUQwByyi276PsAAAdk [info] GET /themes
13:29:30.631 request_id=GEyUQwByyi276PsAAAdk [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:30.632 request_id=GEyUQwByyi276PsAAAdk [info] Sent 200 in 647µs


 57) test Theme Toggle Component renders theme toggle buttons (HydepwnsLiveviewWeb.Themes.ThemeToggleTest)
     test/hydepwns_liveview_web/live/themes/theme_toggle_test.exs:47
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, _html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_toggle_test.exs:49: (test)

13:29:31.105 request_id=GEyUQxyprWyxK6oAAAKF [info] GET /themes
13:29:31.105 request_id=GEyUQxyprWyxK6oAAAKF [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:31.106 request_id=GEyUQxyprWyxK6oAAAKF [info] Sent 200 in 712µs


 58) test resource relationship management user can create a parent-child relationship (HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest)
     test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:47
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Parent Resource 3714", status: "active", type: "folder"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:22: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit__/2

13:29:32.159 request_id=GEyUQ1uGryh-3AQAAAKl [info] GET /themes
13:29:32.160 request_id=GEyUQ1uGryh-3AQAAAKl [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:32.160 request_id=GEyUQ1uGryh-3AQAAAKl [info] Sent 200 in 1ms


 59) test resource relationship management relationship constraints are enforced (HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest)
     test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:162
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Parent Resource 710", status: "active", type: "folder"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:22: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit__/2

13:29:33.260 request_id=GEyUQ50c2Ti53T8AAAkD [info] GET /themes
13:29:33.260 request_id=GEyUQ50c2Ti53T8AAAkD [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:33.260 request_id=GEyUQ50c2Ti53T8AAAkD [info] Sent 200 in 632µs


 60) test resource relationship management user can remove relationships (HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest)
     test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:131
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Parent Resource 774", status: "active", type: "folder"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:22: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit__/2

13:29:34.480 request_id=GEyUQ-XXN6Eicj4AAAkj [info] GET /themes
13:29:34.480 request_id=GEyUQ-XXN6Eicj4AAAkj [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:34.481 request_id=GEyUQ-XXN6Eicj4AAAkj [info] Sent 200 in 862µs


 61) test resource relationship management relationship changes trigger UI updates (HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest)
     test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:199
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Parent Resource 3778", status: "active", type: "folder"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:22: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit__/2

13:29:35.660 request_id=GEyURCwume0QbJQAAA8B [info] GET /themes
13:29:35.660 request_id=GEyURCwume0QbJQAAA8B [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:35.661 request_id=GEyURCwume0QbJQAAA8B [info] Sent 200 in 986µs


 62) test resource relationship management user cannot create circular relationships (HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest)
     test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:103
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Parent Resource 838", status: "active", type: "folder"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:22: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit__/2

13:29:37.571 request_id=GEyURJ4bsPP1-WcAAAWm [info] GET /themes
13:29:37.577 request_id=GEyURJ4bsPP1-WcAAAWm [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:37.581 request_id=GEyURJ4bsPP1-WcAAAWm [info] Sent 200 in 9ms
🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2271.0>}
🟣 MockEventStore.reset called


 63) test resource relationship management user can manage multiple relationships (HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest)
     test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:77
     ** (MatchError) no match of right hand side value: {:error, #Ecto.Changeset<action: :insert, changes: %{content: %{text: "Test content"}, name: "Parent Resource 1925", status: "active", type: "folder"}, errors: [status: {"is invalid", [validation: :inclusion, enum: ["draft", "published", "archived", "deleted"]]}], data: #HydepwnsLiveview.Resources.Resource<>, valid?: false, ...>}
     stacktrace:
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:22: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit_setup_3/1
       test/hydepwns_liveview_web/features/resource_relationship_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest.__ex_unit__/2

🔵 MockEventStore.store_event: order.created for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-1
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-1"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.234951Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-1", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.234958Z]}, resource_id: "test-order-1", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-1"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.234951Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-1", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.234958Z]}, resource_id: "test-order-1", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-1 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2274.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: order.created for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-4"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.239228Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-4", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.239233Z]}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-4"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.239228Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-4", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.239233Z]}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-4 -> 1 events
🔵 MockEventStore.store_event: order.updated for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-4"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.239228Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-4", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.239233Z]}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{status: "submitted"}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.updated"}]}
🔵 MockEventStore.store_event: order.deleted for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-4"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.239228Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-4", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.239233Z]}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{status: "submitted"}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.updated"}, %{data: %{}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-4"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.239228Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-4", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.239233Z]}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{status: "submitted"}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.updated"}, %{data: %{}, resource_id: "test-order-4", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-4 -> 3 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2277.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: order.created for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-3"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.240451Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-3", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.240455Z]}, resource_id: "test-order-3", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🔵 MockEventStore.store_event: order.deleted for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-3"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.240451Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-3", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.240455Z]}, resource_id: "test-order-3", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{}, resource_id: "test-order-3", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-3"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.240451Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-3", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.240455Z]}, resource_id: "test-order-3", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{}, resource_id: "test-order-3", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-3 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2280.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: order.created for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-2"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.241897Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-2", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.241900Z]}, resource_id: "test-order-2", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-2"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.241897Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-2", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.241900Z]}, resource_id: "test-order-2", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-2 -> 1 events
🔵 MockEventStore.store_event: order.updated for Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-2"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.241897Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-2", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.241900Z]}, resource_id: "test-order-2", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{billing_address: "123 Main St", shipping_address: "123 Main St", status: "submitted"}, resource_id: "test-order-2", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.updated"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestOrderResource, "test-order-2"} => [%{data: %{billing_address: nil, cancelled_at: nil, created_at: ~U[2025-06-26 11:29:38.241897Z], customer_id: "customer-1", discount_amount: Decimal.new("0.00"), fulfilled_at: nil, id: "test-order-2", items: [], payment_method: nil, shipping_address: nil, shipping_amount: Decimal.new("0.00"), status: "cart", tax_amount: Decimal.new("0.00"), total_amount: Decimal.new("0.00"), updated_at: ~U[2025-06-26 11:29:38.241900Z]}, resource_id: "test-order-2", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.created"}, %{data: %{billing_address: "123 Main St", shipping_address: "123 Main St", status: "submitted"}, resource_id: "test-order-2", resource_type: HydepwnsLiveview.Resources.TestOrderResource, type: "order.updated"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestOrderResource:test-order-2 -> 2 events
.13:29:38.725 request_id=GEyUROLd_rrEvHcAAAfE [info] GET /themes
13:29:38.725 request_id=GEyUROLd_rrEvHcAAAfE [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:38.726 request_id=GEyUROLd_rrEvHcAAAfE [info] Sent 200 in 713µs


 64) test user can create a new resource (HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest)
     test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:21
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:16: HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest.__ex_unit_setup_2/1
       test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest.__ex_unit__/2

13:29:39.842 request_id=GEyURSVyAk5EdYQAAAfk [info] GET /themes
13:29:39.842 request_id=GEyURSVyAk5EdYQAAAfk [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:39.843 request_id=GEyURSVyAk5EdYQAAAfk [info] Sent 200 in 957µs


 65) test user can delete a resource (HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest)
     test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:41
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:16: HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest.__ex_unit_setup_2/1
       test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest.__ex_unit__/2

13:29:40.997 request_id=GEyURWpRQPCJqKMAAAOF [info] GET /themes
13:29:41.010 request_id=GEyURWpRQPCJqKMAAAOF [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.013 request_id=GEyURWpRQPCJqKMAAAOF [info] Sent 200 in 15ms


 66) test user can edit an existing resource (HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest)
     test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:30
     ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.402.0>}}
     stacktrace:
       (hydepwns_liveview 0.1.0) test/support/resource_system_helper.ex:16: HydepwnsLiveview.TestSupport.ResourceSystemHelper.setup_resource_system/0
       test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:16: HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest.__ex_unit_setup_2/1
       test/hydepwns_liveview_web/features/resource_creation_workflow_test.exs:1: HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest.__ex_unit__/2

13:29:41.625 [error] Error retrieving events: %Ecto.Query.CastError{type: :binary_id, value: "invalid_id", message: "lib/hydepwns_liveview/events/event_operations.ex:261: value `\"invalid_id\"` cannot be dumped to type :binary_id in query:\n\nfrom e0 in HydepwnsLiveview.Events.Core.Event,\n  where: e0.id == ^\"invalid_id\",\n  select: e0\n"}
13:29:41.632 [debug] QUERY OK source="events" db=1.5ms queue=4.1ms
SELECT e0."id", e0."type", e0."resource_id", e0."resource_type", e0."data", e0."metadata", e0."correlation_id", e0."causation_id", e0."timestamp", e0."inserted_at", e0."updated_at" FROM "events" AS e0 WHERE (e0."type" = $1) ["nonexistent_type"]
.13:29:41.635 [debug] QUERY OK source="events" db=2.2ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{key: "value"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.632863Z], "test_event", ~U[2025-06-26 11:29:41.632954Z], ~U[2025-06-26 11:29:41.632954Z], "6d60a7c7-4a36-4b30-ba63-e87f08d7af86"]
...13:29:41.640 [debug] QUERY OK db=0.2ms
begin []
13:29:41.642 [debug] QUERY OK source="events" db=0.6ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{key: "value1"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.637115Z], "test_event_1", ~U[2025-06-26 11:29:41.640482Z], ~U[2025-06-26 11:29:41.640482Z], "9f9365e1-b95d-47a6-be79-b55062a5abef"]
13:29:41.642 [debug] QUERY OK source="events" db=0.1ms
INSERT INTO "events" ("data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) [%{key: "value2"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.637129Z], "test_event_2", ~U[2025-06-26 11:29:41.642069Z], ~U[2025-06-26 11:29:41.642069Z], "f6d89600-6d32-4aa1-a185-a58a02b2a5f7"]
13:29:41.642 [debug] QUERY OK db=0.1ms
commit []
..13:29:41.644 [debug] QUERY OK source="events" db=0.6ms
INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["ca403f11-fffb-4fe2-8f35-9ed15bc8931e", %{key: "value"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.643265Z], "test_event", ~U[2025-06-26 11:29:41.643326Z], ~U[2025-06-26 11:29:41.643326Z], "3b0dcd7c-3e62-4af4-941a-110d6b0df0b3"]
.13:29:41.646 [debug] QUERY OK source="events" db=0.6ms queue=1.1ms
INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["733f5d2a-b6a0-4e99-8f4e-b371a35d4a29", %{key: "value1"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.644427Z], "test_event_1", ~U[2025-06-26 11:29:41.644467Z], ~U[2025-06-26 11:29:41.644467Z], "124b4def-3962-47b2-9d3a-82ecf39d9471"]
13:29:41.647 [debug] QUERY OK source="events" db=0.5ms
INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["bc81af4e-b0ba-4556-bd15-406b1f5f8524", %{key: "value2"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.646336Z], "test_event_2", ~U[2025-06-26 11:29:41.646369Z], ~U[2025-06-26 11:29:41.646369Z], "ada136b5-a27c-4abd-b342-43082c08bbc0"]
13:29:41.648 [debug] QUERY OK source="events" db=1.0ms queue=0.3ms
SELECT e0."id", e0."type", e0."resource_id", e0."resource_type", e0."data", e0."metadata", e0."correlation_id", e0."causation_id", e0."timestamp", e0."inserted_at", e0."updated_at" FROM "events" AS e0 []
13:29:41.649 [debug] QUERY OK source="events" db=0.2ms queue=0.5ms
SELECT e0."id", e0."type", e0."resource_id", e0."resource_type", e0."data", e0."metadata", e0."correlation_id", e0."causation_id", e0."timestamp", e0."inserted_at", e0."updated_at" FROM "events" AS e0 WHERE (e0."id" = $1) ["124b4def-3962-47b2-9d3a-82ecf39d9471"]
13:29:41.650 [debug] QUERY OK source="events" db=0.6ms
SELECT e0."id", e0."type", e0."resource_id", e0."resource_type", e0."data", e0."metadata", e0."correlation_id", e0."causation_id", e0."timestamp", e0."inserted_at", e0."updated_at" FROM "events" AS e0 WHERE (e0."type" = $1) ["test_event_1"]
.13:29:41.650 [debug] QUERY OK source="events" db=0.1ms queue=0.2ms
SELECT e0."id", e0."type", e0."resource_id", e0."resource_type", e0."data", e0."metadata", e0."correlation_id", e0."causation_id", e0."timestamp", e0."inserted_at", e0."updated_at" FROM "events" AS e0 LIMIT $1 [1]
...13:29:41.652 request_id=GEyURZFTz7JrYGUAAAUi [info] GET /themes
13:29:41.652 request_id=GEyURZFTz7JrYGUAAAUi [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.652 request_id=GEyURZFTz7JrYGUAAAUi [info] Sent 200 in 334µs
13:29:41.653 request_id=GEyURZFh9heQbV4AAAVC [info] GET /themes
13:29:41.653 request_id=GEyURZFh9heQbV4AAAVC [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.653 request_id=GEyURZFh9heQbV4AAAVC [info] Sent 200 in 218µs


 67) test renders theme manager page (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:51
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, _view, html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:53: (test)

13:29:41.654 request_id=GEyURZFv7sCfq7sAAAVi [info] GET /themes
13:29:41.654 request_id=GEyURZFv7sCfq7sAAAVi [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]


 68) test deletes a theme (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:126
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:128: (test)

13:29:41.654 request_id=GEyURZFv7sCfq7sAAAVi [info] Sent 200 in 223µs


 69) test sets a theme as default (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:102
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, _html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:108: (test)

13:29:41.654 request_id=GEyURZF8B5hkNrEAAAOl [info] GET /themes
13:29:41.654 request_id=GEyURZF8B5hkNrEAAAOl [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.655 request_id=GEyURZF8B5hkNrEAAAOl [info] Sent 200 in 203µs


 70) test validates theme creation (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:148
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, _html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:150: (test)

13:29:41.655 request_id=GEyURZGGQW6MdJQAAAPF [info] GET /themes
13:29:41.655 request_id=GEyURZGGQW6MdJQAAAPF [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.655 request_id=GEyURZGGQW6MdJQAAAPF [info] Sent 200 in 187µs
13:29:41.656 request_id=GEyURZGRNFQMbRcAAAPl [info] GET /themes
13:29:41.656 request_id=GEyURZGRNFQMbRcAAAPl [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.656 request_id=GEyURZGRNFQMbRcAAAPl [info] Sent 200 in 187µs


 71) test creates a new theme (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:72
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, _html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:74: (test)



 72) test handles theme mode changes (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:210
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, _html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:212: (test)

13:29:41.657 request_id=GEyURZGfbR6L8CUAAAlD [info] GET /themes
13:29:41.657 request_id=GEyURZGfbR6L8CUAAAlD [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]
13:29:41.657 request_id=GEyURZGfbR6L8CUAAAlD [info] Sent 200 in 491µs
13:29:41.658 request_id=GEyURZGvDcRm3P8AAAlj [info] GET /themes
13:29:41.658 request_id=GEyURZGvDcRm3P8AAAlj [debug] Processing with HydepwnsLiveviewWeb.ThemeController.index/2
  Parameters: %{}
  Pipelines: [:browser]


 73) test displays list of themes (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:59
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, _view, html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:65: (test)

13:29:41.658 request_id=GEyURZGvDcRm3P8AAAlj [info] Sent 200 in 197µs


 74) test updates an existing theme (HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest)
     test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:174
     ** (MatchError) no match of right hand side value: {:error, :nosession}
     code: {:ok, view, _html} = live(conn, "/themes")
     stacktrace:
       test/hydepwns_liveview_web/live/themes/theme_manager_live_test.exs:176: (test)

13:29:41.660 [debug] QUERY OK source="events" db=0.7ms queue=1.0ms
INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["9d090732-27a6-4eb4-96a4-77dbc007a44a", %{data: %{description: "Test Description", end_time: ~U[2025-06-26 13:29:41.658802Z], start_time: ~U[2025-06-26 12:29:41.658793Z], title: "Test Event"}, resource_id: "95ff73c5-1f5a-4c87-bbcb-aa3793bcd419", resource_type: "calendar_event"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.658816Z], "calendar_event.created", ~U[2025-06-26 11:29:41.658867Z], ~U[2025-06-26 11:29:41.658867Z], "a3aa3ddb-ff31-4db4-9d47-7506636770f2"]
DEBUG event after create_event: %HydepwnsLiveview.Events.Core.Event{
  __meta__: #Ecto.Schema.Metadata<:loaded, "events">,
  id: "a3aa3ddb-ff31-4db4-9d47-7506636770f2",
  type: "calendar_event.created",
  resource_id: "123",
  resource_type: "test_resource",
  data: %{
    data: %{
      description: "Test Description",
      end_time: ~U[2025-06-26 13:29:41.658802Z],
      start_time: ~U[2025-06-26 12:29:41.658793Z],
      title: "Test Event"
    },
    resource_id: "95ff73c5-1f5a-4c87-bbcb-aa3793bcd419",
    resource_type: "calendar_event"
  },
  metadata: %{},
  correlation_id: "9d090732-27a6-4eb4-96a4-77dbc007a44a",
  causation_id: nil,
  timestamp: ~U[2025-06-26 11:29:41.658816Z],
  inserted_at: ~U[2025-06-26 11:29:41.658867Z],
  updated_at: ~U[2025-06-26 11:29:41.658867Z]
}
13:29:41.665 [debug] QUERY OK source="event_settings" db=2.8ms queue=0.3ms
INSERT INTO "event_settings" ("default_duration","default_status","enable_reminders","event_id","max_events_per_day","reminder_time","timezone","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING "id" [60, "draft", true, "a3aa3ddb-ff31-4db4-9d47-7506636770f2", 10, 30, "UTC", ~N[2025-06-26 11:29:41], ~N[2025-06-26 11:29:41]]
13:29:41.667 [debug] QUERY OK source="event_reminders" db=0.6ms queue=0.2ms
INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["a3aa3ddb-ff31-4db4-9d47-7506636770f2", "test@example.com", ~U[2025-06-26 11:59:41Z], "pending", ~N[2025-06-26 11:29:41], ~N[2025-06-26 11:29:41]]
13:29:41.668 [debug] QUERY OK db=0.0ms
begin []
13:29:41.669 [debug] QUERY OK source="event_settings" db=0.9ms
SELECT e0."id", e0."timezone", e0."default_status", e0."default_duration", e0."max_events_per_day", e0."enable_reminders", e0."reminder_time", e0."event_id", e0."inserted_at", e0."updated_at" FROM "event_settings" AS e0 WHERE (e0."event_id" = $1) ["a3aa3ddb-ff31-4db4-9d47-7506636770f2"]
13:29:41.671 [info] Mock encryption completed
13:29:41.671 [info] Mock email sent to test@example.com
13:29:41.673 [debug] QUERY OK source="event_reminders" db=1.1ms
UPDATE "event_reminders" SET "sent_at" = $1, "status" = $2, "updated_at" = $3 WHERE "id" = $4 [~U[2025-06-26 11:29:41Z], "sent", ~N[2025-06-26 11:29:41], 330]
13:29:41.673 [debug] QUERY OK db=0.0ms
commit []
.13:29:41.674 [debug] QUERY OK source="events" db=0.2ms queue=0.1ms
INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["bd5e741e-2a78-41cf-90ed-5e574bd1443e", %{data: %{description: "Test Description", end_time: ~U[2025-06-26 13:29:41.673623Z], start_time: ~U[2025-06-26 12:29:41.673615Z], title: "Test Event"}, resource_id: "ef227b59-33a7-4bc6-9285-7da232347cf9", resource_type: "calendar_event"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.673639Z], "calendar_event.created", ~U[2025-06-26 11:29:41.673680Z], ~U[2025-06-26 11:29:41.673680Z], "a6228dbf-f298-440a-b7f2-08d9978f8f1f"]
DEBUG event after create_event: %HydepwnsLiveview.Events.Core.Event{
  __meta__: #Ecto.Schema.Metadata<:loaded, "events">,
  id: "a6228dbf-f298-440a-b7f2-08d9978f8f1f",
  type: "calendar_event.created",
  resource_id: "123",
  resource_type: "test_resource",
  data: %{
    data: %{
      description: "Test Description",
      end_time: ~U[2025-06-26 13:29:41.673623Z],
      start_time: ~U[2025-06-26 12:29:41.673615Z],
      title: "Test Event"
    },
    resource_id: "ef227b59-33a7-4bc6-9285-7da232347cf9",
    resource_type: "calendar_event"
  },
  metadata: %{},
  correlation_id: "bd5e741e-2a78-41cf-90ed-5e574bd1443e",
  causation_id: nil,
  timestamp: ~U[2025-06-26 11:29:41.673639Z],
  inserted_at: ~U[2025-06-26 11:29:41.673680Z],
  updated_at: ~U[2025-06-26 11:29:41.673680Z]
}
13:29:41.677 [debug] QUERY OK source="event_settings" db=1.4ms queue=0.4ms
INSERT INTO "event_settings" ("default_duration","default_status","enable_reminders","event_id","max_events_per_day","reminder_time","timezone","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING "id" [60, "draft", true, "a6228dbf-f298-440a-b7f2-08d9978f8f1f", 10, 30, "UTC", ~N[2025-06-26 11:29:41], ~N[2025-06-26 11:29:41]]
13:29:41.678 [debug] QUERY OK source="event_reminders" db=0.5ms queue=0.2ms
INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["a6228dbf-f298-440a-b7f2-08d9978f8f1f", "test@example.com", ~U[2025-06-26 11:59:41Z], "pending", ~N[2025-06-26 11:29:41], ~N[2025-06-26 11:29:41]]
13:29:41.682 [debug] QUERY OK source="event_settings" db=4.1ms
SELECT e0."id", e0."timezone", e0."default_status", e0."default_duration", e0."max_events_per_day", e0."enable_reminders", e0."reminder_time", e0."event_id", e0."inserted_at", e0."updated_at" FROM "event_settings" AS e0 WHERE (e0."event_id" = $1) ["a6228dbf-f298-440a-b7f2-08d9978f8f1f"]
13:29:41.683 [debug] QUERY OK source="event_settings" db=0.4ms queue=0.6ms
DELETE FROM "event_settings" WHERE "id" = $1 [262]
13:29:41.684 [debug] QUERY OK db=0.3ms queue=0.1ms
begin []
13:29:41.685 [debug] QUERY OK source="event_settings" db=0.2ms
SELECT e0."id", e0."timezone", e0."default_status", e0."default_duration", e0."max_events_per_day", e0."enable_reminders", e0."reminder_time", e0."event_id", e0."inserted_at", e0."updated_at" FROM "event_settings" AS e0 WHERE (e0."event_id" = $1) ["a6228dbf-f298-440a-b7f2-08d9978f8f1f"]
13:29:41.686 [debug] QUERY OK source="event_reminders" db=0.6ms
UPDATE "event_reminders" SET "error_message" = $1, "sent_at" = $2, "status" = $3, "updated_at" = $4 WHERE "id" = $5 ["No event settings found", ~U[2025-06-26 11:29:41Z], "failed", ~N[2025-06-26 11:29:41], 331]
13:29:41.687 [debug] QUERY OK db=0.2ms
rollback []
.13:29:41.691 [debug] QUERY OK source="events" db=2.4ms queue=1.0ms
INSERT INTO "events" ("correlation_id","data","metadata","resource_id","resource_type","timestamp","type","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) ["84c0f95b-081a-49f4-a270-37e18a0fd699", %{data: %{description: "Test Description", end_time: ~U[2025-06-26 13:29:41.687756Z], start_time: ~U[2025-06-26 12:29:41.687727Z], title: "Test Event"}, resource_id: "80af082b-9549-481d-b8cc-539565ff8e9e", resource_type: "calendar_event"}, %{}, "123", "test_resource", ~U[2025-06-26 11:29:41.687805Z], "calendar_event.created", ~U[2025-06-26 11:29:41.687950Z], ~U[2025-06-26 11:29:41.687950Z], "d8832f36-60f8-4007-9ae9-ca6e0cc5baaf"]
DEBUG event after create_event: %HydepwnsLiveview.Events.Core.Event{
  __meta__: #Ecto.Schema.Metadata<:loaded, "events">,
  id: "d8832f36-60f8-4007-9ae9-ca6e0cc5baaf",
  type: "calendar_event.created",
  resource_id: "123",
  resource_type: "test_resource",
  data: %{
    data: %{
      description: "Test Description",
      end_time: ~U[2025-06-26 13:29:41.687756Z],
      start_time: ~U[2025-06-26 12:29:41.687727Z],
      title: "Test Event"
    },
    resource_id: "80af082b-9549-481d-b8cc-539565ff8e9e",
    resource_type: "calendar_event"
  },
  metadata: %{},
  correlation_id: "84c0f95b-081a-49f4-a270-37e18a0fd699",
  causation_id: nil,
  timestamp: ~U[2025-06-26 11:29:41.687805Z],
  inserted_at: ~U[2025-06-26 11:29:41.687950Z],
  updated_at: ~U[2025-06-26 11:29:41.687950Z]
}
13:29:41.698 [debug] QUERY OK source="event_settings" db=1.8ms queue=0.9ms
INSERT INTO "event_settings" ("default_duration","default_status","enable_reminders","event_id","max_events_per_day","reminder_time","timezone","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING "id" [60, "draft", true, "d8832f36-60f8-4007-9ae9-ca6e0cc5baaf", 10, 30, "UTC", ~N[2025-06-26 11:29:41], ~N[2025-06-26 11:29:41]]
13:29:41.700 [debug] QUERY OK source="event_reminders" db=0.7ms queue=0.7ms
INSERT INTO "event_reminders" ("event_id","recipient","reminder_time","status","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5,$6) RETURNING "id" ["d8832f36-60f8-4007-9ae9-ca6e0cc5baaf", "test@example.com", ~U[2025-06-26 11:59:41Z], "pending", ~N[2025-06-26 11:29:41], ~N[2025-06-26 11:29:41]]
13:29:41.700 [debug] QUERY OK source="event_reminders" db=0.4ms queue=0.1ms
UPDATE "event_reminders" SET "status" = $1, "updated_at" = $2 WHERE "id" = $3 ["sent", ~N[2025-06-26 11:29:41], 332]
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2378.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: post.created for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-1
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-1"} => [%{data: %{author_id: "user-1", content: "This is a test post content", created_at: ~U[2025-06-26 11:29:41.701170Z], id: "test-post-1", published: false, team_id: "team-1", title: "Test Post", updated_at: ~U[2025-06-26 11:29:41.701174Z]}, resource_id: "test-post-1", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-1"} => [%{data: %{author_id: "user-1", content: "This is a test post content", created_at: ~U[2025-06-26 11:29:41.701170Z], id: "test-post-1", published: false, team_id: "team-1", title: "Test Post", updated_at: ~U[2025-06-26 11:29:41.701174Z]}, resource_id: "test-post-1", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-1 -> 1 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2381.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: post.created for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-4"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.702541Z], id: "test-post-4", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.702544Z]}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-4"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.702541Z], id: "test-post-4", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.702544Z]}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-4 -> 1 events
🔵 MockEventStore.store_event: post.updated for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-4"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.702541Z], id: "test-post-4", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.702544Z]}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{published: true, title: "Updated Title"}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.updated"}]}
🔵 MockEventStore.store_event: post.deleted for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-4
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-4"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.702541Z], id: "test-post-4", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.702544Z]}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{published: true, title: "Updated Title"}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.updated"}, %{data: %{}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-4"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.702541Z], id: "test-post-4", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.702544Z]}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{published: true, title: "Updated Title"}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.updated"}, %{data: %{}, resource_id: "test-post-4", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-4 -> 3 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2384.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: post.created for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-3"} => [%{data: %{author_id: "user-1", content: "Will be deleted", created_at: ~U[2025-06-26 11:29:41.703246Z], id: "test-post-3", published: true, team_id: "team-1", title: "To Delete", updated_at: ~U[2025-06-26 11:29:41.703249Z]}, resource_id: "test-post-3", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🔵 MockEventStore.store_event: post.deleted for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-3
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-3"} => [%{data: %{author_id: "user-1", content: "Will be deleted", created_at: ~U[2025-06-26 11:29:41.703246Z], id: "test-post-3", published: true, team_id: "team-1", title: "To Delete", updated_at: ~U[2025-06-26 11:29:41.703249Z]}, resource_id: "test-post-3", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{}, resource_id: "test-post-3", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.deleted"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-3"} => [%{data: %{author_id: "user-1", content: "Will be deleted", created_at: ~U[2025-06-26 11:29:41.703246Z], id: "test-post-3", published: true, team_id: "team-1", title: "To Delete", updated_at: ~U[2025-06-26 11:29:41.703249Z]}, resource_id: "test-post-3", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{}, resource_id: "test-post-3", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.deleted"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-3 -> 2 events
.🟣 MockEventStore.start_link called
🟣 MockEventStore.start_link result: {:ok, #PID<0.2387.0>}
🟣 MockEventStore.reset called
🔵 MockEventStore.store_event: post.created for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-2"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.703701Z], id: "test-post-2", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.703704Z]}, resource_id: "test-post-2", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-2"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.703701Z], id: "test-post-2", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.703704Z]}, resource_id: "test-post-2", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-2 -> 1 events
🔵 MockEventStore.store_event: post.updated for Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-2
🔵 MockEventStore.store_event: state after update: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-2"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.703701Z], id: "test-post-2", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.703704Z]}, resource_id: "test-post-2", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{content: "Updated content", published: true, title: "Updated Title"}, resource_id: "test-post-2", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.updated"}]}
🟡 MockEventStore.get_events_for_resource: current state: %{{HydepwnsLiveview.Resources.TestPostResource, "test-post-2"} => [%{data: %{author_id: "user-1", content: "Original content", created_at: ~U[2025-06-26 11:29:41.703701Z], id: "test-post-2", published: false, team_id: "team-1", title: "Original Title", updated_at: ~U[2025-06-26 11:29:41.703704Z]}, resource_id: "test-post-2", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.created"}, %{data: %{content: "Updated content", published: true, title: "Updated Title"}, resource_id: "test-post-2", resource_type: HydepwnsLiveview.Resources.TestPostResource, type: "post.updated"}]}
🟡 MockEventStore.get_events_for_resource: Elixir.HydepwnsLiveview.Resources.TestPostResource:test-post-2 -> 2 events
.
Finished in 33.8 seconds (5.9s async, 27.9s sync)
308 tests, 74 failures, 8 skipped

```
