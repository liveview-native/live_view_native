defmodule LiveViewNative.TagEngine do
  @moduledoc """
  For more information on TagEngine please see `Phoenix.LiveView.TagEngine`
  """

  alias Phoenix.LiveView.Tokenizer
  @behaviour EEx.Engine

  @impl true
  def init(opts) do
    {subengine, opts} = Keyword.pop(opts, :subengine, Phoenix.LiveView.Engine)
    tag_handler = Keyword.fetch!(opts, :tag_handler)

    %{
      cont: :text,
      tokens: [],
      subengine: subengine,
      substate: subengine.init(opts),
      file: Keyword.get(opts, :file, "nofile"),
      indentation: Keyword.get(opts, :indentation, 0),
      caller: Keyword.fetch!(opts, :caller),
      previous_token_slot?: false,
      source: Keyword.fetch!(opts, :source),
      tag_handler: tag_handler
    }
  end

  @impl true
  def handle_text(state, meta, text) do
    %{file: file, indentation: indentation, tokens: tokens, cont: cont, source: source} = state
    tokenizer_state = Tokenizer.init(indentation, file, source, state.tag_handler)
    {tokens, cont} = Tokenizer.tokenize(text, meta, tokens, cont, tokenizer_state)

    %{
      state
      | tokens: tokens,
        cont: cont,
        source: state.source
    }
  end

  @impl true
  def handle_body(%{tokens: tokens} = state) do
    tokens = Enum.map(tokens, fn
      {:tag, tag_name, attributes, meta} ->
        {:tag, tag_name, Enum.map(attributes, &replace_interface_with_if/1), meta}
      other -> other
    end)

    Phoenix.LiveView.TagEngine.handle_body(%{state | tokens: tokens})
  end

  defp replace_interface_with_if({":interface-" <> name, value, meta}) do
    expr = case value do
      {:string, value, _value_meta} ->
        {:expr, "get_in(assigns, [:_interface, \"#{name}\"]) == \"#{value}\"", %{line: meta.line, column: meta.column + 5}}
      {:expr, expr, expr_meta} ->
        {:expr, "get_in(assigns, [:_interface, \"#{name}\"]) == #{expr}", expr_meta}
    end

    {":if", expr, meta}
  end

  defp replace_interface_with_if(other),
    do: other

  @impl true
  def handle_expr(%{tokens: tokens} = state, marker, expr) do
    %{state | tokens: [{:expr, marker, expr} | tokens]}
  end

  @impl true
  def handle_begin(state) do
    Phoenix.LiveView.TagEngine.handle_begin(state)
  end

  @impl true
  def handle_end(state) do
    Phoenix.LiveView.TagEngine.handle_end(state)
  end
end
