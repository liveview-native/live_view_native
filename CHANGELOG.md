# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* `lvn.setup` is now brokwn into two tasks: `lvn.setup.config` and `lvn.setup.gen`, the former uses
a codegen to inject into your application. There are yet to be addressed edge cases with this, see Known Issues
* the `style` attribute was introduced in `live_view_native_stylesheet`. See that library for more information
* more progress on stability and performance has been made for the SwiftUI client
* `lvn.setup.config` should gracefully exit if unexpected config formats are encountered or if files are missing
* `LiveViewNative.PluginError` to allow for better error messaging
* `lvn.setup.config` now had a default value of `Y` for prompt during codegen

### Changed

* `lvn.setup.config` will now insert after the last `config` function rather than before the first found `import_config`
* `lvn.setup.config` will now group dependencies together first by file path then patch function
* `LiveViewNative.fetch_plugin!/1` will now raise `LiveViewNative.PluginError` with instructions on how to resolve the error
* Improved documentation to `LiveViewNative` module for enabling existing liveviews for native
