defmodule Kantele.Output.Macros do
  @moduledoc """
  Helper macros for defining semantic colors
  """

  @doc """
  Define a semantic color

  Available options:
  - foreground
  - background
  - underline
  """
  defmacro color(tag_name, options) do
    options =
      options
      |> Enum.map(fn {key, value} ->
        {to_string(key), to_string(value)}
      end)
      |> Enum.into(%{})

    quote do
      def transform_tag({:open, unquote(tag_name), attributes}) do
        attributes = Map.merge(attributes, unquote(Macro.escape(options)))
        {:open, "color", attributes}
      end

      def transform_tag({:close, unquote(tag_name)}), do: {:close, "color"}
    end
  end
end

defmodule Kantele.Output.SemanticColors do
  @moduledoc """
  Transform semantic tags into color tags
  """

  @behaviour Kalevala.Output

  import Kantele.Output.Macros

  alias Kalevala.Output.Context

  @impl true
  def init(opts) do
    %Context{
      data: [],
      opts: opts
    }
  end

  @impl true
  def post_parse(context), do: context

  @impl true
  def parse(tag, context) do
    tag = transform_tag(tag)
    Map.put(context, :data, context.data ++ [tag])
  end

  color("character", foreground: "yellow")
  color("item", foreground: "cyan")
  color("text", foreground: "green")
  color("room-title", foreground: "blue", underline: true)
  color("hp", foreground: "red")
  color("sp", foreground: "blue")
  color("ep", foreground: "169,114,218")

  def transform_tag(tag), do: tag
end

defmodule Kantele.Output.AdminTags do
  @moduledoc """
  Parse admin specific tags

  Display things like item instance ids when present
  """

  @behaviour Kalevala.Output

  import Kalevala.Character.View.Macro, only: [sigil_i: 2]

  alias Kalevala.Output.Context

  @impl true
  def init(opts) do
    %Context{
      data: [],
      opts: opts,
      meta: %{
        tag_stack: []
      }
    }
  end

  @impl true
  def post_parse(context), do: context

  @impl true
  def parse({:open, "item-instance", attributes}, context) do
    tag_stack = [attributes | context.meta.tag_stack]
    meta = Map.put(context.meta, :tag_stack, tag_stack)

    Map.put(context, :meta, meta)
  end

  def parse({:close, "item-instance"}, context) do
    [attributes | tag_stack] = context.meta.tag_stack
    meta = Map.put(context.meta, :tag_stack, tag_stack)

    tags = [
      {:open, "color", %{"foreground" => "95,95,95"}},
      ~i(##{attributes["id"]}),
      {:close, "color"},
    ]

    context
    |> Map.put(:data, context.data ++ tags)
    |> Map.put(:meta, meta)
  end

  def parse(datum, context) do
    Map.put(context, :data, context.data ++ [datum])
  end
end
