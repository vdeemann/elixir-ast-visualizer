defmodule AstVisualizer do
  def print_ast(ast), do: IO.puts(inspect(ast) <> "\n" <> tree(ast))
  def visualize_ast(ast), do: inspect(ast) <> "\n" <> tree(ast)
  def print_ast_colored(ast), do: IO.puts(color(ast) <> "\n" <> tree(ast, "", &color/1))

  defp tree(ast, p \\ "", c \\ &inspect/1)
  defp tree(t, p, c) when is_tuple(t), do: kids(Tuple.to_list(t), p, c)
  defp tree(l, p, c) when is_list(l), do: kids(l, p, c)
  defp tree(x, p, c), do: p <> c.(x)

  defp kids([], _, _), do: ""
  defp kids([x], p, c) do
    s = "#{p}└── #{c.(x)}"
    if big?(x), do: s <> "\n" <> tree(x, p <> "    ", c), else: s
  end
  defp kids([h|t], p, c) do
    s = "#{p}├── #{c.(h)}"
    head = if big?(h), do: s <> "\n" <> tree(h, p <> "│   ", c), else: s
    head <> "\n" <> kids(t, p, c)
  end

  defp big?(t) when is_tuple(t), do: tuple_size(t) > 0 && Enum.any?(Tuple.to_list(t), &(is_tuple(&1) || is_list(&1)))
  defp big?(l) when is_list(l), do: l != [] && Enum.any?(l, &(is_tuple(&1) || is_list(&1)))
  defp big?(_), do: false

  defp color(a) when is_atom(a), do: "\e[34m:#{a}\e[0m"
  defp color(s) when is_binary(s), do: "\e[32m\"#{s}\"\e[0m"
  defp color(n) when is_number(n), do: "\e[36m#{n}\e[0m"
  defp color(x), do: inspect(x)

  def analyze_ast(ast) do
    {n, d, f, v, l} = count(ast)
    IO.puts("Nodes: #{n}, Depth: #{d}, Funcs: #{f}, Vars: #{v}, Literals: #{l}")
    print_ast(ast)
  end

  defp count({f, _, a}, d \\ 0) when is_atom(f) and is_list(a) do
    {cn, cd, cf, cv, cl} = a |> Enum.map(&count(&1, d+1)) |> sum({0,d,0,0,0})
    {cn+1, cd, cf+1, cv, cl}
  end
  defp count({v, _, c}, d) when is_atom(v) and is_atom(c), do: {1, d, 0, 1, 0}
  defp count(t, d) when is_tuple(t) do
    {cn, cd, cf, cv, cl} = t |> Tuple.to_list() |> Enum.map(&count(&1, d+1)) |> sum({0,d,0,0,0})
    {cn+1, cd, cf, cv, cl}
  end
  defp count(l, d) when is_list(l) do
    {cn, cd, cf, cv, cl} = l |> Enum.map(&count(&1, d+1)) |> sum({0,d,0,0,0})
    {cn+1, cd, cf, cv, cl}
  end
  defp count(_, d), do: {1, d, 0, 0, 1}

  defp sum(list, acc), do: Enum.reduce(list, acc, fn {n1,d1,f1,v1,l1}, {n2,d2,f2,v2,l2} -> {n1+n2, max(d1,d2), f1+f2, v1+v2, l1+l2} end)
end