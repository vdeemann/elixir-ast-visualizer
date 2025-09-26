defmodule AstVisualizer do
  @moduledoc "A compact AST visualizer for Elixir with tree-style output."

  def print_ast(ast), do: IO.puts(inspect(ast) <> "\n" <> build_tree(ast, ""))
  def visualize_ast(ast), do: inspect(ast) <> "\n" <> build_tree(ast, "")
  def print_ast_colored(ast), do: IO.puts(colorize(ast) <> "\n" <> build_tree_colored(ast, ""))

  # Core tree building - handles all types
  defp build_tree(ast, prefix) do
    case ast do
      t when is_tuple(t) -> build_children(Tuple.to_list(t), prefix)
      l when is_list(l) -> build_children(l, prefix)
      leaf -> "#{prefix}#{inspect(leaf)}"
    end
  end

  # Build children with proper tree connectors
  defp build_children([], _), do: ""
  defp build_children([last], prefix) do
    connector = "#{prefix}└── #{inspect(last)}"
    if expandable?(last), do: connector <> "\n" <> build_tree(last, prefix <> "    "), else: connector
  end
  defp build_children([h | t], prefix) do
    connector = "#{prefix}├── #{inspect(h)}"
    head_part = if expandable?(h), do: connector <> "\n" <> build_tree(h, prefix <> "│   "), else: connector
    head_part <> "\n" <> build_children(t, prefix)
  end

  # Simple expandability check
  defp expandable?(t) when is_tuple(t), do: tuple_size(t) > 0 && Enum.any?(Tuple.to_list(t), &complex?/1)
  defp expandable?(l) when is_list(l), do: length(l) > 0 && Enum.any?(l, &complex?/1)
  defp expandable?(_), do: false

  defp complex?(x) when is_tuple(x), do: tuple_size(x) > 0
  defp complex?(x) when is_list(x), do: length(x) > 0
  defp complex?(_), do: false

  # Colored version (simplified)
  defp build_tree_colored(ast, prefix) do
    case ast do
      t when is_tuple(t) -> build_children_colored(Tuple.to_list(t), prefix)
      l when is_list(l) -> build_children_colored(l, prefix)
      leaf -> "#{prefix}#{colorize(leaf)}"
    end
  end

  defp build_children_colored([], _), do: ""
  defp build_children_colored([last], prefix) do
    connector = "#{prefix}└── #{colorize(last)}"
    if expandable?(last), do: connector <> "\n" <> build_tree_colored(last, prefix <> "    "), else: connector
  end
  defp build_children_colored([h | t], prefix) do
    connector = "#{prefix}├── #{colorize(h)}"
    head_part = if expandable?(h), do: connector <> "\n" <> build_tree_colored(h, prefix <> "│   "), else: connector
    head_part <> "\n" <> build_children_colored(t, prefix)
  end

  defp colorize(atom) when is_atom(atom), do: "\e[34m:#{atom}\e[0m"
  defp colorize(str) when is_binary(str), do: "\e[32m\"#{str}\"\e[0m"
  defp colorize(num) when is_number(num), do: "\e[36m#{num}\e[0m"
  defp colorize(other), do: inspect(other)

  # Optional: Simple analysis
  def analyze_ast(ast) do
    {nodes, depth, funcs, vars, lits} = stats(ast, 0)
    IO.puts("\nNodes: #{nodes}, Depth: #{depth}, Funcs: #{funcs}, Vars: #{vars}, Literals: #{lits}\n")
    print_ast(ast)
  end

  defp stats({f, _, args}, d) when is_atom(f) and is_list(args) do
    {cn, cd, cf, cv, cl} = args |> Enum.map(&stats(&1, d + 1)) |> Enum.reduce({0,d,0,0,0}, &merge_stats/2)
    {cn + 1, cd, cf + 1, cv, cl}
  end
  defp stats({v, _, ctx}, d) when is_atom(v) and is_atom(ctx), do: {1, d, 0, 1, 0}
  defp stats(t, d) when is_tuple(t) do
    {cn, cd, cf, cv, cl} = t |> Tuple.to_list() |> Enum.map(&stats(&1, d + 1)) |> Enum.reduce({0,d,0,0,0}, &merge_stats/2)
    {cn + 1, cd, cf, cv, cl}
  end
  defp stats(l, d) when is_list(l) do
    {cn, cd, cf, cv, cl} = l |> Enum.map(&stats(&1, d + 1)) |> Enum.reduce({0,d,0,0,0}, &merge_stats/2)
    {cn + 1, cd, cf, cv, cl}
  end
  defp stats(_, d), do: {1, d, 0, 0, 1}

  defp merge_stats({n1,d1,f1,v1,l1}, {n2,d2,f2,v2,l2}), do: {n1+n2, max(d1,d2), f1+f2, v1+v2, l1+l2}
end