defmodule Mix.LiveViewNative.CodeGen do
  @moduledoc false

  alias Sourceror.Zipper

  def patch(source, change, opts \\ []) do
    case build_patches(source, change, opts) do
      {:error, msg} -> {:error, msg}
      patches when is_list(patches) ->
        {:ok, Sourceror.patch_string(source, patches)}
    end
  end

  defp build_patches(source, change, opts) do
    case {Keyword.get(opts, :merge), Keyword.get(opts, :inject)} do
      {merge, _} when is_function(merge) ->
        case merge.(source, change) do
          :error -> build_patches(source, change, Keyword.delete(opts, :merge))
          patches -> patches
        end
      {_, {:before, matcher}} -> inject_before(source, change, matcher, Keyword.get(opts, :path))
      {_, {:after, matcher}} -> inject_after(source, change, matcher, Keyword.get(opts, :path))
      {_, :head} -> inject_head(source, change)
      {_, :eof} -> inject_eof(source, change)
      _ ->
        {:error, Keyword.get(opts, :fail_msg, "")}
    end
  end

  defp inject_before(source, change, matcher, path) do
    quoted_source = Sourceror.parse_string!(source)
    case get_matched_range(quoted_source, matcher) do
      {:ok, %{start: [line: line, column: column], end: _}} ->
        range = %{
          start: [line: line, column: column],
          end: [line: line, column: column]
        }

        [build_patch(range, change)]
      :error ->
        msg =
          """
          The following change failed to be applied to #{path}

          #{change}
          """
        {:error, msg}
    end
  end

  defp inject_after(source, change, matcher, path) do
    quoted_source = Sourceror.parse_string!(source)
    case get_matched_range(quoted_source, matcher) do
      {:ok, %{start: [line: _, column: column], end: [line: line, column: _]}} ->
        range = %{
          start: [line: line + 1, column: column],
          end: [line: line + 1, column: column]
        }

        [build_patch(range, change)]
      :error ->
        msg =
          """
          The following change failed to be applied to #{path}

          #{change}
          """

        {:error, msg}
    end
  end

  defp inject_head(source, change) do
    quoted_source = Sourceror.parse_string!(source)
    %{start: [line: line, column: column], end: _} = Sourceror.get_range(quoted_source)

    range = %{
      start: [line: line, column: column],
      end: [line: line, column: column]
    }

    [build_patch(range, change)]
  end

  defp inject_eof(source, change) do
    quoted_source = Sourceror.parse_string!(source)
    %{start: _, end: [line: line, column: column]} = Sourceror.get_range(quoted_source)

    range = %{
      start: [line: line + 1, column: column],
      end: [line: line + 1, column: column]
    }

    [build_patch(range, change)]
  end

  defp get_matched_range(quoted, {:first, matcher}) do
    quoted
    |> Zipper.zip()
    |> Zipper.find(matcher)
    |> case do
      nil -> :error
      found -> {:ok, Zipper.node(found) |> Sourceror.get_range()}
    end
  end

  defp get_matched_range(quoted, {:last, matcher}) do
    quoted
    |> Zipper.zip()
    |> Zipper.find_all(matcher)
    |> case do
      [] -> :error
      found -> {:ok, List.last(found) |> Zipper.node() |> Sourceror.get_range()}
    end
  end

  defp get_matched_range(quoted, matcher) when is_function(matcher),
    do: get_matched_range(quoted, {:first, matcher})

  def build_patch(range, change),
    do: %{
      range: range,
      change: change
    }
end
