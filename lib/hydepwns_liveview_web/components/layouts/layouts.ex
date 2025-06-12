defmodule HydepwnsLiveviewWeb.Components.Layout.Layouts do
  use Phoenix.Component

  use Phoenix.Template,
    root: "lib/hydepwns_liveview_web",
    namespace: HydepwnsLiveviewWeb.Components.Layout

  embed_templates "components/layout/layouts/*"
end
