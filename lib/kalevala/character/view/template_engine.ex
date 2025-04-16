defmodule Kalevala.Character.View.TemplateEngine do
  @moduledoc """
  An EEx Engine that returns IO data instead of a string.

  This is used to efficiently render telnet-safe templates
  and structured output in controllers and views.
  """

  @behaviour EEx.Engine

  @impl true
  def init(_opts) do
    %{
      iodata: [],
      dynamic: [],
      vars_count: 0
    }
  end

  @impl true
  def handle_begin(state) do
    %{state | iodata: [], dynamic: []}
  end

  @impl true
  def handle_end(state), do: handle_body(state)

  @impl true
  def handle_body(%{iodata: iodata, dynamic: dynamic}) do
    iodata = Enum.reverse(iodata)
    {:__block__, [], Enum.reverse([iodata | dynamic])}
  end

  @impl true
  def handle_text(state, _meta, text) do
    %{state | iodata: [text | state.iodata]}
  end

  @impl true
  def handle_expr(state, "=", ast) do
    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)
    var = Macro.var(:"arg#{state.vars_count}", __MODULE__)
    dynamic = [quote(do: unquote(var) = unquote(ast)) | state.dynamic]
    %{state | dynamic: dynamic, iodata: [var | state.iodata], vars_count: state.vars_count + 1}
  end

  def handle_expr(state, "", ast) do
    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)
    %{state | dynamic: [ast | state.dynamic]}
  end

  def handle_expr(state, marker, ast) do
    EEx.Engine.handle_expr(state, marker, ast)
  end
end
