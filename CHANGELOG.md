## v0.2

### New Features and Improvements

* Fix ets table generation
* Fix regression with external HTML templates when using `render_native/1`
* Use default Phoenix context for non-LVN render
* Added support for LiveView Native stylesheets (PR [#64](https://github.com/liveview-native/live_view_native/pull/64))
* Added support for Phoenix layouts to native platforms (PR [#68](https://github.com/liveview-native/live_view_native/pull/68))
* Improved `mix lvn.install` task (PR [#75](https://github.com/liveview-native/live_view_native/pull/75))

###

### Breaking Changes

* Standardized connection format (PR [#60](https://github.com/liveview-native/live_view_native/pull/60))
* Removed modifiers system (PR [#82](https://github.com/liveview-native/live_view_native/pull/82))
* Renamed `web` platform to `html` (PR [#81](https://github.com/liveview-native/live_view_native/pull/81))