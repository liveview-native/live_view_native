defmodule Mix.Tasks.ExDocGuidesTest do
  use ExUnit.Case
  alias Mix.Tasks.ExDocGuides

  test "make_ex_doc_friendly/1 removes Mix.install/2 section and adds Run in Livebook badge" do
    content = """
    ```elixir
    Mix.install(
      [
        {:kino_live_view_native, github: "liveview-native/kino_live_view_native"}
      ],
      config: [
        live_view_native: [plugins: [LiveViewNativeSwiftUi]]
      ]
    )

    KinoLiveViewNative.start([])
    ```
    """

    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") =~
             "[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%filename.livemd)"
  end

  test "make_ex_doc_friendly/1 removes initial Kino boilerplate in smart cells" do
    content = """
    require KinoLiveViewNative.Livebook
    import KinoLiveViewNative.Livebook
    import Kernel, except: [defmodule: 2]

    """

    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") == """
           """
  end

  test "make_ex_doc_friendly/1 removes ending Kino boilerplate in smart cells" do
    url = Enum.random(["/", "/path", "path/subpath", "path/1"])
    action = Enum.random([":index", ":show", ":new", ":create", ":edit", ":update", ":delete"])

    content = """
    |> KinoLiveViewNative.register("#{url}", "#{action}")

    import KinoLiveViewNative.Livebook, only: []
    import Kernel
    :ok
    """

    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") == """
           """
  end

  test "make_ex_doc_friendly/1 removes navigation" do
    content = """
    ## Section Above

    ## Navigation

    <div style="display: flex; align-items: center; width: 100%; justify-content: space-between; font-size: 1rem; color: #61758a; background-color: #f0f5f9; height: 4rem; padding: 0 1rem; border-radius: 1rem;">
    <div style="display: flex; margin-left: auto;">
    <a style="display: flex; color: #61758a; margin-right: 1rem;" href="https://livebook.dev/run?url=https%3A%2F%2Fhexdocs.pm%2Flive_view_native%2F0.1.2%2Fcreate-a-swiftui-application.livemd">Create a SwiftUI Application</a>
    <i class="ri-arrow-right-fill"></i>
    </div>
    </div>

    ## Section Below
    """

    # We currently clear any code below navigation to make the regex easier.
    assert ExDocGuides.make_ex_doc_friendly(content, "filename.livemd") == """
           ## Section Above

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
