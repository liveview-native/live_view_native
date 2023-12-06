defmodule Mix.Tasks.Lvn.Install do
  @moduledoc "Installer Mix task for LiveView Native: `mix lvn.install`"
  use Mix.Task

  @requirements ["app.config"]

  @shortdoc "Installs LiveView Native."
  def run(args) do
    {parsed_args, _, _} = OptionParser.parse(args, strict: [namespace: :string])

    # Get all Mix tasks for LiveView Native client libraries
    valid_mix_tasks = get_installer_mix_tasks()
    host_project_config = get_host_project_config(parsed_args)

    run_all_install_tasks(valid_mix_tasks, host_project_config)
    native_config = merge_native_config(valid_mix_tasks)
    generate_native_exs_if_needed(host_project_config, native_config)
    update_config_exs_if_needed(host_project_config)
    clean_build_path(host_project_config)
    format_config_files()

    IO.puts("\nYour Phoenix app is ready to use LiveView Native!\n")
    IO.puts("Platform-specific project files have been placed in the \"native\" directory\n")

    :ok
  end

  ###

  defp run_all_install_tasks(mix_tasks, host_project_config) do
    mix_tasks
    |> Enum.map(&prompt_task_settings/1)
    |> Enum.map(&(run_install_task(&1, host_project_config)))
  end

  defp prompt_task_settings(%{client_name: client_name, prompts: [_ | _] = prompts} = task) do
    prompts
    |> Enum.reduce_while({:ok, task}, fn {prompt_key, prompt_settings}, {:ok, acc} ->
      case prompt_task_setting(prompt_settings, client_name) do
        {:error, message} ->
          Owl.IO.puts([Owl.Data.tag("#{client_name}: #{message}", :yellow)])

          {:halt, {:error, acc}}

        result ->
          settings = Map.get(acc, :settings, %{})
          updated_settings = Map.put(settings, prompt_key, result)

          {:cont, {:ok, Map.put(acc, :settings, updated_settings)}}
      end
    end)
  end

  defp prompt_task_setting(%{ignore: true}, _client_name), do: true

  defp prompt_task_setting(%{type: :confirm, label: label} = task, client_name) do
    if Owl.IO.confirm(message: "#{client_name}: #{label}", default: true) do
      if is_function(task[:on_yes]), do: apply(task[:on_yes], [])
    else
      if is_function(task[:on_no]), do: apply(task[:on_no], [])
    end
  end

  defp prompt_task_setting(%{type: :multiselect, label: label, options: options, default: default} = task, client_name) do
    default_label = Map.get(task, :default_label, inspect(default))

    case Owl.IO.multiselect(options, label: "#{client_name}: #{label} (Space-delimited, leave blank for default: #{default_label})") do
      [] ->
        default || []

      result ->
        result
    end
  end

  defp prompt_task_setting(_task, _client_name), do: nil

  defp run_install_task(result, host_project_config) do
    case result do
      {:ok, %{client_name: client_name, mix_task: mix_task, settings: settings}} ->
        Owl.IO.puts([Owl.Data.tag("* generating ", :green), "#{client_name} project files"])

        mix_task.run(["--host-project-config", host_project_config, "--task-settings", settings])

      _ ->
        :skipped
    end
  end

  defp get_installer_mix_tasks do
    Mix.Task.load_all()
    |> Enum.filter(&(function_exported?(&1, :lvn_install_config, 0)))
    |> Enum.map(fn module ->
      module
      |> apply(:lvn_install_config, [])
      |> Map.put(:mix_task, module)
    end)
  end

  defp get_host_project_config(parsed_args) do
    # Define some paths for the host project
    current_path = File.cwd!()
    mix_config_path = Path.join(current_path, "mix.exs")
    build_path = Path.join(current_path, "_build")

    # Ask the user some questiosn about the native project configuration
    preferred_route = prompt_config_option("What path should native clients connect to by default?", "/")
    preferred_prod_url = prompt_config_option("What URL will you use in production?", "example.com")

    %{
      app_config_path: Path.join(current_path, "/config/config.exs"),
      app_namespace: parsed_args[:namespace] || infer_app_namespace(mix_config_path),
      build_path: build_path,
      current_path: current_path,
      libs_path: Path.join(build_path, "dev/lib"),
      mix_config_path: mix_config_path,
      native_path: Path.join(current_path, "native"),
      preferred_prod_url: preferred_prod_url,
      preferred_route: preferred_route
    }
  end

  defp prompt_config_option(prompt_message, default_value) do
    "#{prompt_message} (Leave blank for default: \"#{default_value}\")\n"
    |> IO.gets()
    |> String.trim()
    |> default_if_blank(default_value)
  end

  defp default_if_blank(value, default_value) do
    if value == "", do: default_value, else: value
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

  defp merge_native_config(mix_tasks) do
    mix_tasks
    |> Enum.reduce(%{}, fn %{mix_config: mix_config}, acc ->
      DeepMerge.deep_merge(acc, mix_config)
    end)
  end

  defp generate_native_exs_if_needed(%{current_path: current_path}, %{} = native_config) do
    native_config_path = Path.join(current_path, "/config/native.exs")
    native_config_already_exists? = File.exists?(native_config_path)
    generate_native_config? = if native_config_already_exists?, do: Owl.IO.confirm(message: "native.exs already exists, regenerate it?", default: false), else: true

    if generate_native_config? do
      Owl.IO.puts([ Owl.Data.tag("* creating ", :green), "config/native.exs"])
      lvn_configuration = native_exs_body(native_config)
      File.write(native_config_path, lvn_configuration)

      :ok
    else
      IO.puts("native.exs already exists, skipping...")
    end
  end

  defp native_exs_body(%{} = native_config) do
    config_body =
      native_config
      |> Enum.map(fn {key, config} ->
        config_value = inspect(config)
        config_value_formatted = String.slice(config_value, 1, String.length(config_value) - 2)

        "config :#{key}, #{config_value_formatted}"
      end)
      |> Enum.join("\n\n")

    """
    # This file is responsible for configuring LiveView Native.
    # It is auto-generated when running `mix lvn.install`.
    import Config

    #{config_body}
    """
  end

  defp update_config_exs_if_needed(%{app_config_path: app_config_path}) do
    # Update project's config.exs to import native.exs if needed.
    import_string = "import_config \"native.exs\""
    full_import_string = Enum.join(["\n", "# Import LiveView Native configuration", import_string], "\n")
    {:ok, app_config_body} = File.read(app_config_path)

    if String.contains?(app_config_body, import_string) do
      IO.puts("config.exs already imports native.exs, skipping...")
    else
      Owl.IO.puts([ Owl.Data.tag("* updating ", :yellow), "config/config.exs"])

      {:ok, app_config} = File.open(app_config_path, [:write])
      updated_app_config_body = app_config_body <> "\n" <> full_import_string

      IO.binwrite(app_config, updated_app_config_body)
      File.close(app_config)
    end
  end

  defp format_config_files do
    System.cmd("mix", ["format", "*.exs"], cd: "config")
  end

  defp clean_build_path(%{build_path: build_path}) do
    # Clear _build path to ensure it's rebuilt with new Config
    File.rm_rf(build_path)
  end
end
