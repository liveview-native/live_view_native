defmodule LiveViewNativeTest.Switch do
  use LiveViewNative,
    format: :switch,
    component: LiveViewNativeTest.Switch.Component,
    module_suffix: :Switch,
    template_engine: LiveViewNative.Template.Engine,
    test_client: %LiveViewNativeTest.Switch.TestClient{}
end
