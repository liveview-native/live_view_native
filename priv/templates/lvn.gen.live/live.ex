defmodule <%= inspect context.web_module %>.<%= inspect context.schema_module %>Live.<%= inspect context.module_suffix %> do
  use <%= inspect context.native_module %>, [:render_component, format: <%= inspect context.format %>]
end
