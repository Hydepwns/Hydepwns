defmodule HydepwnsLiveviewWeb.Layouts do
  use Phoenix.Component

  use Phoenix.Template,
    root: "lib/hydepwns_liveview_web",
    namespace: HydepwnsLiveviewWeb

  import HydepwnsLiveviewWeb.Components.Common.ThemeToggle, only: [theme_toggle: 1]
  import HydepwnsLiveviewWeb.Components.UI.DebugGrid, only: [debug_grid: 1]
  import Phoenix.Controller, only: [get_csrf_token: 0]

  use Phoenix.VerifiedRoutes,
    endpoint: HydepwnsLiveviewWeb.Endpoint,
    router: HydepwnsLiveviewWeb.Router,
    statics: HydepwnsLiveviewWeb.static_paths()

  embed_templates "layouts/*"
end
