defmodule LiveViewNativeTest.HomeLive do
  use LiveViewNative.Component,
    format: :gameboy

  embed_templates "gameboy/home_live*"
end