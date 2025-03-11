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

  # Only keep imports that are actually used in the embedded templates
  embed_templates "layouts/*"
end
