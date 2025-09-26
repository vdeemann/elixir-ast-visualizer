defmodule AstVisualizer do
  @moduledoc """
  A vertical Abstract Syntax Tree visualizer for Elixir.
  
  Provides functions to print AST structures in a readable tree format,
  making it easier to understand the structure of quoted expressions.
  """

  @doc """
  Prints the AST of a quoted expression in a vertical tree format.
  
  ## Examples
  
      iex> quoted = quote do: x + y
      iex> AstVisualizer.print_ast(quoted)
      {:+, [context: Elixir, import: Kernel], [{:x, [], Elixir}, {:y, [], Elixir}]}
      ├── :+
      ├── [context: Elixir, import: Kernel]
      │   ├── context: Elixir
      │   └── import: Kernel
      └── [{:x, [], Elixir}, {:y, [], Elixir}]
          ├── {:x, [], Elixir}
          │   ├── :x
          │   ├── []
          │   └── Elixir
          └── {:y, [], Elixir}
              ├── :y
              ├── []
              └── Elixir
  """
  def print_ast(ast) do
    IO.puts("#{inspect(ast)}")
    print_tree(ast, "")
  end

  @doc """
  Returns the AST visualization as a string instead of printing it.
  """
  def visualize_ast(ast) do
    header = "#{inspect(ast)}\n"
    tree = build_tree_string(ast, "")
    header <> tree
  end

  # Private functions for tree building

  defp print_tree(ast, prefix) do
    tree_string = build_tree_string(ast, prefix)
    IO.puts(tree_string)
  end

  defp build_tree_string(ast, prefix) do
    case ast do
      # Handle tuples (most AST nodes)
      tuple when is_tuple(tuple) ->
        build_tuple_tree(tuple, prefix)
      
      # Handle lists
      list when is_list(list) ->
        build_list_tree(list, prefix)
      
      # Handle atoms, numbers, strings, etc.
      leaf ->
        "#{prefix}#{inspect(leaf)}"
    end
  end

  defp build_tuple_tree(tuple, prefix) do
    elements = Tuple.to_list(tuple)
    build_elements_tree(elements, prefix)
  end

  defp build_list_tree([], _prefix), do: ""
  
  defp build_list_tree(list, prefix) do
    build_elements_tree(list, prefix)
  end

  defp build_elements_tree([], _prefix), do: ""
  
  defp build_elements_tree([element], prefix) do
    # Last element uses └── 
    child_prefix = prefix <> "    "
    current = "#{prefix}└── "
    
    case needs_expansion?(element) do
      true ->
        current <> "#{inspect(element)}\n" <> 
        build_tree_string(element, child_prefix)
      false ->
        current <> "#{inspect(element)}"
    end
  end
  
  defp build_elements_tree([head | tail], prefix) do
    # Non-last elements use ├── 
    child_prefix = prefix <> "│   "
    current = "#{prefix}├── "
    
    head_string = case needs_expansion?(head) do
      true ->
        current <> "#{inspect(head)}\n" <> 
        build_tree_string(head, child_prefix)
      false ->
        current <> "#{inspect(head)}"
    end
    
    head_string <> "\n" <> build_elements_tree(tail, prefix)
  end

  defp needs_expansion?(element) do
    case element do
      # Expand tuples with more than just atoms/simple values
      tuple when is_tuple(tuple) ->
        tuple_size(tuple) > 0 and has_complex_elements?(Tuple.to_list(tuple))
      
      # Expand non-empty lists that contain complex elements
      list when is_list(list) ->
        length(list) > 0 and has_complex_elements?(list)
      
      # Don't expand simple values
      _ when is_atom(element) or is_number(element) or is_binary(element) ->
        false
      
      # Expand everything else
      _ ->
        true
    end
  end

  defp has_complex_elements?(elements) do
    Enum.any?(elements, fn element ->
      case element do
        tuple when is_tuple(tuple) -> tuple_size(tuple) > 0
        list when is_list(list) -> length(list) > 0
        _ -> false
      end
    end)
  end

  @doc """
  Pretty prints an AST with syntax highlighting (basic version).
  Uses ANSI colors if supported by the terminal.
  """
  def print_ast_colored(ast) do
    IO.puts(colorize_ast(ast))
    print_tree_colored(ast, "")
  end

  defp colorize_ast(ast) do
    case ast do
      atom when is_atom(atom) ->
        IO.ANSI.blue() <> ":#{atom}" <> IO.ANSI.reset()
      
      binary when is_binary(binary) ->
        IO.ANSI.green() <> "\"#{binary}\"" <> IO.ANSI.reset()
      
      number when is_number(number) ->
        IO.ANSI.cyan() <> "#{number}" <> IO.ANSI.reset()
      
      _ ->
        "#{inspect(ast)}"
    end
  end

  defp print_tree_colored(ast, prefix) do
    case ast do
      tuple when is_tuple(tuple) ->
        elements = Tuple.to_list(tuple)
        print_elements_colored(elements, prefix)
      
      list when is_list(list) ->
        print_elements_colored(list, prefix)
      
      leaf ->
        IO.puts("#{prefix}#{colorize_ast(leaf)}")
    end
  end

  defp print_elements_colored([], _prefix), do: :ok
  
  defp print_elements_colored([element], prefix) do
    child_prefix = prefix <> "    "
    IO.puts("#{prefix}└── #{colorize_ast(element)}")
    
    if needs_expansion?(element) do
      print_tree_colored(element, child_prefix)
    end
  end
  
  defp print_elements_colored([head | tail], prefix) do
    child_prefix = prefix <> "│   "
    IO.puts("#{prefix}├── #{colorize_ast(head)}")
    
    if needs_expansion?(head) do
      print_tree_colored(head, child_prefix)
    end
    
    print_elements_colored(tail, prefix)
  end

  @doc """
  Analyzes and prints statistics about the AST structure.
  """
  def analyze_ast(ast) do
    stats = gather_stats(ast)
    
    IO.puts("\n=== AST Analysis ===")
    IO.puts("Total nodes: #{stats.total_nodes}")
    IO.puts("Max depth: #{stats.max_depth}")
    IO.puts("Function calls: #{stats.function_calls}")
    IO.puts("Variables: #{stats.variables}")
    IO.puts("Literals: #{stats.literals}")
    IO.puts("==================\n")
    
    print_ast(ast)
  end

  defp gather_stats(ast, depth \\ 0) do
    base_stats = %{
      total_nodes: 0,
      max_depth: depth,
      function_calls: 0,
      variables: 0,
      literals: 0
    }
    
    case ast do
      # Function call pattern {func, meta, args}
      {func, _meta, args} when is_atom(func) and is_list(args) ->
        child_stats = args
        |> Enum.map(&gather_stats(&1, depth + 1))
        |> Enum.reduce(base_stats, &merge_stats/2)
        
        %{child_stats | 
          total_nodes: child_stats.total_nodes + 1,
          function_calls: child_stats.function_calls + 1,
          max_depth: max(child_stats.max_depth, depth)
        }
      
      # Variable pattern {var, meta, context}
      {var, _meta, context} when is_atom(var) and is_atom(context) ->
        %{base_stats |
          total_nodes: 1,
          variables: 1,
          max_depth: depth
        }
      
      # Tuple
      tuple when is_tuple(tuple) ->
        elements = Tuple.to_list(tuple)
        child_stats = elements
        |> Enum.map(&gather_stats(&1, depth + 1))
        |> Enum.reduce(base_stats, &merge_stats/2)
        
        %{child_stats |
          total_nodes: child_stats.total_nodes + 1,
          max_depth: max(child_stats.max_depth, depth)
        }
      
      # List
      list when is_list(list) ->
        child_stats = list
        |> Enum.map(&gather_stats(&1, depth + 1))
        |> Enum.reduce(base_stats, &merge_stats/2)
        
        %{child_stats |
          total_nodes: child_stats.total_nodes + 1,
          max_depth: max(child_stats.max_depth, depth)
        }
      
      # Literals (atoms, numbers, strings, etc.)
      _ ->
        %{base_stats |
          total_nodes: 1,
          literals: 1,
          max_depth: depth
        }
    end
  end

  defp merge_stats(stats1, stats2) do
    %{
      total_nodes: stats1.total_nodes + stats2.total_nodes,
      max_depth: max(stats1.max_depth, stats2.max_depth),
      function_calls: stats1.function_calls + stats2.function_calls,
      variables: stats1.variables + stats2.variables,
      literals: stats1.literals + stats2.literals
    }
  end
end