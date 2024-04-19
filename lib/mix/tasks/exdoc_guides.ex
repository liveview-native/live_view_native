
defmodule Mix.Tasks.ExDocGuides do
  @moduledoc "Generates ex_doc friendly guides from Livebook notebooks"
  use Mix.Task
  def run(_args) do
    # clean up old notebooks
    File.rm_rf("guides/ex_doc_notebooks")
    File.mkdir("guides/ex_doc_notebooks")

    File.ls!("guides/livebooks") |> Enum.filter(fn file_name -> file_name =~ ".livemd" end)
    |> Enum.each(fn file_name ->
      ex_doc_friendly_content = make_ex_doc_friendly(File.read!("guides/livebooks/#{file_name}"), file_name)
      File.write!("guides/ex_doc_notebooks/#{Path.basename(file_name, ".livemd")}.md", ex_doc_friendly_content)
    end)
  end

  def make_ex_doc_friendly(content, file_name) do
    content
    |> replace_setup_section_with_badge(file_name)
    |> remove_kino_boilerplate()
    |> convert_details_sections()
  end

  defp replace_setup_section_with_badge(content, file_name) do
    badge = "[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%livebooks%#{file_name})"
    String.replace(content, ~r/```elixir(.|\n)+?```/, badge, global: false)
  end

  defp remove_kino_boilerplate(content) do
    content
    |> String.replace("""
    require Server.Livebook
    import Server.Livebook
    import Kernel, except: [defmodule: 2]

    """, "")
    |> String.replace(~r/\|\> Server\.SmartCells\.LiveViewNative\.register\(\".+\"\)\n\nimport Server\.Livebook, only: \[\]\nimport Kernel\n:ok\n/, "")
    |> String.replace(~r/\|\> Server\.SmartCells\.RenderComponent\.register\(\)\n\nimport Server\.Livebook, only: \[\]\nimport Kernel\n:ok\n/, "")
  end

  defp convert_details_sections(content) do
    # Details sections do not properly render on ex_doc, so we convert them to headers
    Regex.replace(~r/<details.+\n<summary>([^<]+)<\/summary>((.|\n)+?)(?=<\/details>)<\/details>/, content, fn _full, title, content ->
      "### #{title}#{content}"
    end)
  end
end
