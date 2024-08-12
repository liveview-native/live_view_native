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
          #{IO.ANSI.red()}#{IO.ANSI.bright()}The following change failed to be applied to #{path}#{IO.ANSI.reset()}

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
          #{IO.ANSI.red()}#{IO.ANSI.bright()}The following change failed to be applied to #{path}#{IO.ANSI.reset()}

          #{change}
          """

        {:error, msg}
    end
  end

  defp inject_head(_source, change) do
    range = %{
      start: [line: 1, column: 1],
      end: [line: 1, column: 1]
    }

    [build_patch(range, change)]
  end

  defp inject_eof(source, change) do
    line =
      source
      |> String.split("\n")
      |> length()

    range = %{
      start: [line: line, column: 1],
      end: [line: line, column: 1]
    }

    [build_patch(range, change)]
  end

  defp get_matched_range(quoted, matcher) when is_function(matcher),
    do: get_matched_range(quoted, {:first, matcher})

  defp get_matched_range(quoted, {position, matcher}) do
    quoted
    |> Zipper.zip()
    |> find(position, matcher)
    |> case do
      :error -> :error
      {:ok, node} -> {:ok, Sourceror.get_range(node)}
    end
  end

  defp find(zipper, :first, matcher) do
    zipper
    |> Zipper.find(matcher)
    |> case do
      nil -> :error
      zipper -> {:ok, Zipper.node(zipper)}
    end
  end

  defp find(zipper, :last, matcher) do
    {_zipper, last_match} =
      Zipper.traverse(zipper, :error, fn(zipper, last_match) ->
        node = Zipper.node(zipper)

        if matcher.(node) do
          {zipper, {:ok, node}}
        else
          {zipper, last_match}
        end
      end)

    last_match
  end

  def build_patch(range, change),
    do: %{
      range: range,
      change: change
    }
end
