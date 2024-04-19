defmodule Mix.Tasks.ExDocGuidesTest do
  use ExUnit.Case
  alias Mix.Tasks.ExDocGuides

  test "make_ex_doc_friendly/1 removes Mix.install/2 section and adds Run in Livebook badge" do
    content = """
    ```elixir
    notebook_path = __ENV__.file |> String.split("#") |> hd()

    Mix.install(
      [
        {:kino_live_view_native, github: "liveview-native/kino_live_view_native"}
      ],
      config: [
        server: [
          {ServerWeb.Endpoint,
          [
            server: true,
            url: [host: "localhost"],
            adapter: Phoenix.Endpoint.Cowboy2Adapter,
            render_errors: [
              formats: [html: ServerWeb.ErrorHTML, json: ServerWeb.ErrorJSON],
              layout: false
            ],
            pubsub_server: Server.PubSub,
            live_view: [signing_salt: "JSgdVVL6"],
            http: [ip: {127, 0, 0, 1}, port: 4000],
            secret_key_base: String.duplicate("a", 64),
            live_reload: [
              patterns: [
                ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg|styles)$",
                ~r/\#{notebook_path}$/
              ]
            ]
          ]}
        ],
        kino: [
          group_leader: Process.group_leader()
        ],
        phoenix: [
          template_engines: [neex: LiveViewNative.Engine]
        ],
        phoenix_template: [format_encoders: [swiftui: Phoenix.HTML.Engine]],
        mime: [
          types: %{"text/swiftui" => ["swiftui"], "text/styles" => ["styles"]}
        ],
        live_view_native: [plugins: [LiveViewNative.SwiftUI]],
        live_view_native_stylesheet: [
          content: [
            swiftui: [
              "lib/**/*swiftui*",
              notebook_path
            ]
          ],
          output: "priv/static/assets"
        ]
      ],
      force: true
    )
    ```
    """
    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") =~
             "[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%livebooks%filename.livemd)"
  end

  test "make_ex_doc_friendly/1 removes initial Kino boilerplate in smart cells" do
    content = """
    require Server.Livebook
    import Server.Livebook
    import Kernel, except: [defmodule: 2]

    """

    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") == """
           """
  end

  test "make_ex_doc_friendly/1 removes ending Kino boilerplate in LiveViewNative smart cells" do
    url = Enum.random(["/", "/path", "path/subpath", "path/1"])

    content = """
    |> Server.SmartCells.LiveViewNative.register("#{url}")

    import Server.Livebook, only: []
    import Kernel
    :ok
    """

    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") == """
           """
  end

  test "make_ex_doc_friendly/1 removes ending Kino boilerplate in Render Component smart cells" do
    content = """
    |> Server.SmartCells.RenderComponent.register()

    import Server.Livebook, only: []
    import Kernel
    :ok
    """

    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") == """
           """
  end


  test "make_ex_doc_friendly/1 convert details sections" do
    content = """
    <details style="background-color: lightgreen; padding: 1rem; margin: 1rem 0;">
    <summary>What do these options mean?</summary>

    * **Product Name:** The name of the application. This can be any valid name. We've chosen `Guides`.
    * **Organization Identifier:** A reverse DNS string that uniquely identifies your organization. If you don't have a company identifier, [Apple recomends](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app) using `com.example.your_name` where `your_name` is your organization or personal name.
    * **Interface:**: Xcode generates an interface file that includes all your source code's internal and public declarations when using the Assistant editor, the Related Items, or the Navigate menu. Select `SwiftUI` since we're building a SwiftUI application.
    * **Language:** Determines which language Xcode should use for the project. Select `Swift`.
    </details>
    """
    result = ExDocGuides.make_ex_doc_friendly(content, "filename.livemd")
    refute result =~ "details"
    assert result =~ """
            ### What do these options mean?

            * **Product Name:** The name of the application. This can be any valid name. We've chosen `Guides`.
            * **Organization Identifier:** A reverse DNS string that uniquely identifies your organization. If you don't have a company identifier, [Apple recomends](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app) using `com.example.your_name` where `your_name` is your organization or personal name.
            * **Interface:**: Xcode generates an interface file that includes all your source code's internal and public declarations when using the Assistant editor, the Related Items, or the Navigate menu. Select `SwiftUI` since we're building a SwiftUI application.
            * **Language:** Determines which language Xcode should use for the project. Select `Swift`.
            """
  end
end
