defmodule AstVisualizer do
  @moduledoc "Simple AST tree visualizer. Does one thing well: show AST structure."

  def print(ast), do: IO.puts(tree(ast))
  
  defp tree(ast), do: inspect(ast) <> "\n" <> walk(ast, "")
  
  defp walk(tuple, prefix) when is_tuple(tuple) do
    tuple |> Tuple.to_list() |> children(prefix)
  end
  defp walk(list, prefix) when is_list(list) do
    children(list, prefix)
  end
  defp walk(leaf, prefix) do
    prefix <> inspect(leaf)
  end
  
  defp children([]), do: ""
  defp children([last], prefix) do
    "#{prefix}└── #{inspect(last)}" <> maybe_expand(last, prefix <> "    ")
  end
  defp children([head | tail], prefix) do
    "#{prefix}├── #{inspect(head)}" <> 
    maybe_expand(head, prefix <> "│   ") <> 
    "\n" <> children(tail, prefix)
  end
  
  defp maybe_expand(node, prefix) do
    if expandable?(node) do
      "\n" <> walk(node, prefix)
    else
      ""
    end
  end
  
  defp expandable?(t) when is_tuple(t), do: tuple_size(t) > 0
  defp expandable?(l) when is_list(l), do: l != []
  defp expandable?(_), do: false
end