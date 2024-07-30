defmodule Mix.LiveViewNative.CodeGen do
  @moduledoc false

  alias Sourceror.Zipper

  def patch(source, change, opts \\ []) do
    patches = build_patches(source, change, opts)

    Sourceror.patch_string(source, patches)
  end

  defp build_patches(source, change, opts) do
    case {Keyword.get(opts, :merge), Keyword.get(opts, :inject)} do
      {merge, _} when is_function(merge) ->
        case merge.(source, change) do
          :error -> build_patches(source, change, Keyword.delete(opts, :merge))
          patches -> patches
        end
      {_, {:before, matcher}} -> inject_before(source, change, matcher)
      {_, {:after, matcher}} -> inject_after(source, change, matcher)
      {_, :head} -> inject_head(source, change)
      {_, :eof} -> inject_eof(source, change)
      _ ->
        if fail_msg = Keyword.get(opts, :fail_msg) do
          Mix.shell.info(fail_msg)
        end

        []
    end
  end

  defp inject_before(source, change, matcher) do
    quoted_source = Sourceror.parse_string!(source)
    case get_matched_range(quoted_source, matcher) do
      {:ok, %{start: [line: line, column: column], end: _}} ->
        range = %{
          start: [line: line, column: column],
          end: [line: line, column: column]
        }

        [build_patch(range, change)]
      :error -> []
    end
  end

  defp inject_after(source, change, matcher) do
    quoted_source = Sourceror.parse_string!(source)
    case get_matched_range(quoted_source, matcher) do
      {:ok, %{start: [line: _, column: column], end: [line: line, column: _]}} ->
        range = %{
          start: [line: line + 1, column: column],
          end: [line: line + 1, column: column]
        }

        [build_patch(range, change)]
      :error ->
        """
        The following change tried to be applied to
        """
        []
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

  defp get_matched_range(quoted, matcher) do
    quoted
    |> Zipper.zip()
    |> Zipper.find(matcher)
    |> case do
      nil -> :error
      found -> {:ok, Zipper.node(found) |> Sourceror.get_range()}
    end
  end

  def build_patch(range, change),
    do: %{
      range: range,
      change: change
    }
end
