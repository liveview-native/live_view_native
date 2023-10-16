defmodule Mix.Tasks.Lvn.Install do
  @moduledoc "Installer Mix task for LiveView Native: `mix lvn.install`"
  use Mix.Task

  @requirements ["app.config"]

  @template_projects_repo "https://github.com/liveview-native/liveview-native-template-projects"
  @template_projects_version "0.0.1"

  @shortdoc "Installs LiveView Native."
  def run(args) do
    {parsed_args, _, _} = OptionParser.parse(args, strict: [namespace: :string])

    # Define some paths for the host project
    current_path = File.cwd!()
    mix_config_path = Path.join(current_path, "mix.exs")
    app_config_path = Path.join(current_path, "/config/config.exs")
    app_namespace = parsed_args[:namespace] || infer_app_namespace(mix_config_path)
    build_path = Path.join(current_path, "_build")
    libs_path = Path.join(build_path, "dev/lib")

    # Ask the user some questions about their app
    preferred_route_input =
      IO.gets(
        "What path should native clients connect to by default? Leave blank for default: \"/\")\n"
      )

    preferred_prod_url_input =
      IO.gets("What URL will you use in production? Leave blank for default: \"example.com\")\n")

    preferred_route = String.trim(preferred_route_input)
    _preferred_route = if preferred_route == "", do: "/", else: preferred_route
    preferred_prod_url = String.trim(preferred_prod_url_input)
    _preferred_prod_url = if preferred_prod_url == "", do: "example.com", else: preferred_prod_url

    # Get a list of compiled libraries
    libs = File.ls!(libs_path)

    # Clone the liveview-native-template-projects repo. This repo contains
    # templates for various native platforms in their respective tools
    # (Xcode, Android Studio, etc.)
    clone_template_projects()
    template_projects_path = Path.join(build_path, "lvn_tmp/liveview-native-template-projects")
    template_libs = File.ls!(template_projects_path)

    # Find libraries compiled for the host project that have available
    # template projects
    supported_libs = Enum.filter(libs, &(&1 in template_libs))

    # Run the install script for each template project. Install scripts are
    # responsible for generating platform-specific template projects and return
    # information about that platform to be applied to the host project's Mix
    # configuration.
    platform_names =
      Enum.map(supported_libs, fn lib ->
        status_message("configuring", "#{lib}")

        # Run the project-specific install script, passing info about the host
        # Phoenix project.
        lib_path = Path.join(template_projects_path, "/#{lib}")
        script_path = Path.join(lib_path, "/install.exs")

        cmd_opts = [
          script_path,
          "--app-name",
          app_namespace,
          "--app-path",
          current_path,
          "--platform-lib-path",
          lib_path
        ]

        with {platform_name, 0} <- System.cmd("elixir", cmd_opts) do
          String.trim(platform_name)
        end
      end)

    generate_native_exs_if_needed(current_path, platform_names)
    update_config_exs_if_needed(app_config_path)

    # Clear _build path to ensure it's rebuilt with new Config
    File.rm_rf(build_path)

    IO.puts("\nYour Phoenix app is ready to use LiveView Native!\n")
    IO.puts("Platform-specific project files have been placed in the \"native\" directory\n")

    :ok
  end

  ###

  defp clone_template_projects do
    with {:ok, current_path} <- File.cwd(),
         tmp_path <- Path.join(current_path, "_build/lvn_tmp"),
         _ <- File.rm_rf(tmp_path),
         :ok <- File.mkdir(tmp_path) do
      status_message("downloading", "template project files")

      System.cmd("git", [
        "clone",
        "-b",
        @template_projects_version,
        @template_projects_repo,
        tmp_path <> "/liveview-native-template-projects"
      ])
    end
  end

  def infer_app_namespace(config_path) do
    with {:ok, config} <- File.read(config_path),
         {:ok, mix_project_ast} <- Code.string_to_quoted(config),
         {:ok, namespace} <- find_mix_project_namespace(mix_project_ast) do
      "#{namespace}"
    else
      _ ->
        raise "Could not infer Mix project namespace from mix.exs. Please provide it manually using the --namespace argument."
    end
  end

  defp find_mix_project_namespace(ast) do
    case ast do
      ast when is_list(ast) ->
        ast
        |> Enum.reduce_while({:error, :cannot_infer_app_name}, fn node, _acc ->
          {status, result} = find_mix_project_namespace(node)
          acc_op = if status == :ok, do: :halt, else: :cont

          {acc_op, {status, result}}
        end)

      {:defmodule, _, [{:__aliases__, _, [namespace, :MixProject]} | _rest]} ->
        {:ok, namespace}

      {:__block__, _, contents} ->
        find_mix_project_namespace(contents)

      _ ->
        {:error, :cannot_infer_app_name}
    end
  end

  defp generate_native_exs_if_needed(current_path, platform_names) do
    platform_names_string = Enum.join(platform_names, ",")
    native_config_path = Path.join(current_path, "/config/native.exs")

    if File.exists?(native_config_path) do
      IO.puts("native.exs already exists, skipping...")
    else
      status_message("creating", "config/native.exs")

      # Generate native.exs and write it to config path
      lvn_configuration = native_exs_body(platform_names_string)
      {:ok, native_config} = File.open(native_config_path, [:write])
      IO.binwrite(native_config, lvn_configuration)
      File.close(native_config)

      :ok
    end
  end

  defp update_config_exs_if_needed(app_config_path) do
    # Update project's config.exs to import native.exs if needed.
    import_string = "import_config \"native.exs\""
    {:ok, app_config_body} = File.read(app_config_path)

    if String.contains?(app_config_body, import_string) do
      IO.puts("config.exs already imports native.exs, skipping...")
    else
      status_message("updating", "config/config.exs")

      {:ok, app_config} = File.open(app_config_path, [:write])
      updated_app_config_body = app_config_body <> "\n" <> import_string

      IO.binwrite(app_config, updated_app_config_body)
      File.close(app_config)
    end
  end

  defp native_exs_body(platform_names_string) do
    """
    # This file is responsible for configuring LiveView Native.
    # It is auto-generated when running `mix lvn.install`.
    import Config

    config :live_view_native, plugins: [#{platform_names_string}]
    """
  end

  defp status_message(label, message) do
    formatted_message = IO.ANSI.green() <> "* #{label} " <> IO.ANSI.reset() <> message

    IO.puts(formatted_message)
  end
end
