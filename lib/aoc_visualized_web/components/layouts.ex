defmodule AocVisualizedWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use AocVisualizedWeb, :controller` and
  `use AocVisualizedWeb, :live_view`.
  """
  use AocVisualizedWeb, :html

  embed_templates "layouts/*"
end
