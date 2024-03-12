defmodule <%= context.web_module %>.Layouts.<%= context.module_suffix %> do
  use <%= context.native_module %>, [:layout, format: <%= inspect context.format %>]

  embed_templates "layouts_<%= context.format %>/*"
end
