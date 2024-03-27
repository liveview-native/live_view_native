# Native Navigation

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%livebooks%native-navigation.livemd)

## Overview

This guide will teach you how to create multi-page applications using LiveView Native. We will cover navigation patterns specific to native applications and how to reuse the existing navigation patterns available in LiveView.

Before diving in, you should have a basic understanding of navigation in LiveView. You should be familiar with the [redirect/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#redirect/2), [push_patch/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#push_patch/2) and [push_navigate/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#push_navigate/2) functions, which are used to trigger navigation from within a LiveView. Additionally, you should know how to define routes in the router using the [live/4](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live/4) macro.

