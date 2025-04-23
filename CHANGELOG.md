# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0]

### Added

- LiveViewNative.Template.Parser - a new Elixir parser for the LVN template syntax
- Parser supports boolean attributes
- Server-Side support for LiveComponent
- Server-Side support for rendering child LiveView
- LiveViewNativeTest
- ensure duplicate IDs raise in tests
- LVN.concat/2
- :interface- special attribute support in tags
- async_result/1
- render_upload support in LiveViewNativeTest
- support single quotes to wrap attribute values in template parser
- LVN Commands
- LiveViewNative.Template.Engine
- LiveViewNative.Component.Declarative
- Template parser supports namespaced attribute keys
- Template parser ignores doctype tags at top of document
- Template parser raw_string converts nodes to string

### Changed

- `LiveViewNative.Component` no longer imports `Phoenix.Component.to_form/2`
- `LiveViewNative.LiveView` now requires the `dispatch_to` function to determine which module will be used for rendering
- Migrated many functions out of LiveViewNative.TagEngine to LiveViewNative.Template.Engine
- **breaking backwards incompatible change** function components are now always arity 2 instead of arity # 
- _interface value is injected into each assigns for function components

### Fixed

- Resolved import issues between Phoenix.Component, LiveViewNative.Component, and plugin.component

## [0.3.1] 2024-10-02

### Added

* interface normalizer [#200] allow for interface data to be normalized by the client libs

### Changed

### Fixed

## [0.3.0] - 2024-08-21

### Added

- `lvn.setup` is now brokwn into two tasks: `lvn.setup.config` and `lvn.setup.gen`, the former uses
a codegen to inject into your application. There are yet to be addressed edge cases with this, see Known Issues
- the `style` attribute was introduced in `live_view_native_stylesheet`. See that library for more information
- more progress on stability and performance has been made for the SwiftUI client
- `lvn.setup.config` should gracefully exit if unexpected config formats are encountered or if files are missing
- `LiveViewNative.PluginError` to allow for better error messaging
- `lvn.setup.config` now had a default value of `Y` for prompt during codegen

### Changed

- `lvn.setup.config` will now insert after the last `config` function rather than before the first found `import_config`
- `lvn.setup.config` will now group dependencies together first by file path then patch function
- `LiveViewNative.fetch_plugin!/1` will now raise `LiveViewNative.PluginError` with instructions on how to resolve the error
- Improved documentation to `LiveViewNative` module for enabling existing liveviews for native
