defmodule HydepwnsLiveviewWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use HydepwnsLiveviewWeb, :controller` and
  `use HydepwnsLiveviewWeb, :live_view`.
  """
  use HydepwnsLiveviewWeb, :html

  # Import core components first - limit to what we need
  import HydepwnsLiveviewWeb.CoreComponents, except: [header_table: 1, nav: 1, theme_toggle: 1]

  # Import UI components that are used
  import HydepwnsLiveviewWeb.Components.UI.LayoutComponents
  import HydepwnsLiveviewWeb.Components.UI.DebugGrid
  import HydepwnsLiveviewWeb.Components.ThemeToggle

  embed_templates "layouts/*"
end
