## v0.3.0-rc.3

*Note that v0.3.0-rc.2 was skipped due to a bad release issue*

### Breaking changes sine RC.1

* the SwiftUI UtilityClasses stylesheet has been removed in favor of using `style` attr

### New

* `lvn.setup` is now brokwn into two tasks: `lvn.setup.config` and `lvn.setup.gen`, the former uses
a codegen to inject into your application. There are yet to be addressed edge cases with this, see Known Issues
* the `style` attribute was introduced in `live_view_native_stylesheet`. See that library for more information
* more progress on stability and performance has been made for the SwiftUI client

### Known Issues

* The codegen configuration is intended to be used with new projects, projects that have deviated from the standard config/config.exs format
and are not using environment config files such as config/dev.exs will see a broken installation process. This will be addressed
prior to v0.3.0 final
