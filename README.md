# AST Visualizer for Elixir

A compact and elegant Abstract Syntax Tree (AST) visualizer for Elixir that displays quoted expressions in a readable tree format. Perfect for understanding macro expansions, debugging metaprogramming code, and learning how Elixir parses expressions.

## Features

- 🌳 **Tree-style visualization** - Clean left-to-right tree format with Unicode box-drawing characters
- 🎨 **Syntax highlighting** - Optional ANSI color support for better readability
- 📊 **AST analysis** - Statistics about nodes, depth, function calls, variables, and literals
- 🚀 **Lightweight** - Single file, no dependencies
- 🔧 **Easy integration** - Drop into any Elixir project

## Installation

Simply download the `ast_visualizer.ex` file and load it in your project:

```elixir
Code.require_file("path/to/ast_visualizer.ex")
```

## Usage

### Basic Visualization

```elixir
# Visualize a simple expression
quoted = quote do: x + y
AstVisualizer.print_ast(quoted)
```

**Output:**
```
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
```

### Complete Example

Here's a practical example showing how to use AST Visualizer to understand macro expansion:

```elixir
Code.require_file("ast_visualizer.ex")

defmodule Canvas do
  @default [fg: "black", bg: "white", font: "Merriweather"]
  
  def draw_text(text, options \\ []) do
    # Capture the AST of our keyword merge operation
    quoted_expr = quote do
      options = Keyword.merge(@default, options)
    end
    
    # Visualize the AST structure
    AstVisualizer.print_ast(quoted_expr)
    
    # Continue with normal function logic
    IO.puts("Drawing text #{inspect(text)}")
    IO.puts("Foreground:  #{options[:fg]}")
    IO.puts("Background:  #{Keyword.get(options, :bg)}")
    IO.puts("Font:        #{Keyword.get(options, :font)}")
    IO.puts("Pattern:     #{Keyword.get(options, :pattern, "solid")}")
    IO.puts("Style:       #{inspect(Keyword.get_values(options, :style))}")
  end
end

# Test the visualization
Canvas.draw_text("Hello World", [fg: "red", style: :bold])
```

**Sample Output:**
```
{:=, [], [{:options, [], Elixir}, {{:., [], [{:__aliases__, [alias: false], [:Keyword]}, :merge]}, [], [{:@, [line: 2], [{:default, [line: 2], nil}]}, {:options, [], Elixir}]}]}
├── :=
├── []
└── [{:options, [], Elixir}, {{:., [], [...]}]
    ├── {:options, [], Elixir}
    │   ├── :options
    │   ├── []
    │   └── Elixir
    └── {{:., [], [...]}, [], [...]}
        ├── {:., [], [...]}
        │   ├── :.
        │   ├── []
        │   └── [{:__aliases__, [alias: false], [:Keyword]}, :merge]
        │       ├── {:__aliases__, [alias: false], [:Keyword]}
        │       └── :merge
        └── [{:@, [line: 2], [...]}, {:options, [], Elixir}]
            ├── {:@, [line: 2], [...]}
            └── {:options, [], Elixir}

Drawing text "Hello World"
Foreground:  red
Background:  white
Font:        Merriweather
Pattern:     solid
Style:       [:bold]
```

## API Reference

### Core Functions

#### `print_ast(ast)`
Prints the AST with full tree visualization to stdout.

```elixir
quoted = quote do: [1, 2, 3] |> Enum.map(&(&1 * 2))
AstVisualizer.print_ast(quoted)
```

#### `visualize_ast(ast)`
Returns the AST visualization as a string instead of printing.

```elixir
quoted = quote do: if true, do: :yes, else: :no
tree_string = AstVisualizer.visualize_ast(quoted)
File.write!("ast_output.txt", tree_string)
```

#### `print_ast_colored(ast)`
Prints the AST with ANSI syntax highlighting.

```elixir
quoted = quote do: "hello" <> " " <> "world"
AstVisualizer.print_ast_colored(quoted)
```

**Color scheme:**
- 🔵 **Blue** - Atoms (`:atom`)
- 🟢 **Green** - Strings (`"string"`)
- 🔵 **Cyan** - Numbers (`42`, `3.14`)

#### `analyze_ast(ast)`
Provides detailed statistics about the AST structure.

```elixir
quoted = quote do
  defmodule MyModule do
    def hello(name), do: "Hello, #{name}!"
  end
end

AstVisualizer.analyze_ast(quoted)
```

**Output:**
```
=== AST Analysis ===
Total nodes: 15
Max depth: 4
Function calls: 3
Variables: 2
Literals: 4
==================
```

## Common Use Cases

### 1. Understanding Macro Expansions
```elixir
# See how unless expands
quoted = quote do: unless false, do: "yes"
AstVisualizer.print_ast(quoted)
```

### 2. Debugging Complex Expressions
```elixir
# Visualize pipe operators
quoted = quote do: [1,2,3] |> Enum.filter(&odd?/1) |> Enum.sum()
AstVisualizer.print_ast(quoted)
```

### 3. Learning Pattern Matching
```elixir
# See how pattern matching compiles
quoted = quote do: %{name: name, age: age} = user
AstVisualizer.print_ast(quoted)
```

### 4. Exploring Metaprogramming
```elixir
# Understand code generation
ast = quote do
  def dynamic_function(unquote(name)) do
    unquote(body)
  end
end
AstVisualizer.print_ast(ast)
```

## Tips & Best Practices

- **Start simple** - Begin with basic expressions before exploring complex macros
- **Use colored output** - `print_ast_colored/1` makes large trees easier to read
- **Save to files** - Use `visualize_ast/1` to capture output for documentation
- **Combine with analysis** - Use `analyze_ast/1` to get quantitative insights
- **Interactive exploration** - Great for use in IEx sessions

## Contributing

This tool fills a gap in the Elixir ecosystem - there are currently no dedicated AST tree visualizers available as Hex packages. Contributions are welcome!

## License

[Add your preferred license here]

---

*Happy metaprogramming! 🧙‍♂️*
