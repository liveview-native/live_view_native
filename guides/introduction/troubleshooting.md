# Troubleshooting

Sometimes you might get blocked by a compiler error or other issue during installation. If this happens, you might try clearing your build directory and recompiling from a clean state. To do this, run the following commands from your project's root directory:

```bash
rm -rf _build
rm -rf deps
mix deps.get
mix compile
```

This should ideally resolve without error. If it doesn't, feel free to [submit an issue](https://github.com/liveview-native/live_view_native/issues/new) on the GitHub repo for this library or ask in the `#liveview-native` channel of [Elixir Slack](https://elixir-lang.slack.com/); a member of the LiveView Native core team or other community member should be able to help you troubleshoot the problem.