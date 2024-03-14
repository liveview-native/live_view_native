defmodule <%= inspect context.web_module %>.Layouts.<%= inspect context.module_suffix %> do
  use <%= inspect context.native_module %>, [:layout, format: <%= inspect context.format %>]

  embed_templates "layouts_<%= context.format %>/*"
end
