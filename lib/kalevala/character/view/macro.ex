defmodule Kalevala.Character.View.Macro do
  @moduledoc """
  Sigil helpers for rendering views in Kalevala.

  Provides:

    - `~E` for EEx templating using `TemplateEngine`
    - `~i` for interpolated IO lists (safe for output processing)
  """

  @doc """
  `~E` sigil compiles EEx templates into IO data using Kalevala's engine.

  Example:

      ~E\"\"\"
      Hello <%= @character.name %>!
      \"\"\"
  """
  defmacro sigil_E({:<<>>, _, [expr]}, opts) do
    string =
      EEx.compile_string(expr,
        line: __CALLER__.line + 1,
        sigil_opts: opts,
        engine: Kalevala.Character.View.TemplateEngine
      )

    quote do
      Kalevala.Character.View.trim_lines(unquote(string))
    end
  end

  @doc """
  `~i` sigil is used to write literal text with interpolations returned as an IO list.
  """
  defmacro sigil_i({:<<>>, _, text}, _) do
    Enum.map(text, &sigil_i_unwrap/1)
  end

  defp sigil_i_unwrap({:"::", _, interpolation}) do
    [text | _] = interpolation
    {_, _, [text]} = text

    quote do
      to_string(unquote(text))
    end
  end

  defp sigil_i_unwrap(text) when is_binary(text) do
    if Code.ensure_loaded?(:elixir_interpolation) and function_exported?(:elixir_interpolation, :unescape_string, 1) do
      :elixir_interpolation.unescape_string(text)
    else
      # Avoid deprecated :elixir_tokenizer fallback
      text
    end
  end
end
