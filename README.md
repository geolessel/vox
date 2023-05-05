# Vox

1. find all the files to process
   `Vox.Builder.FileFinder`
2. compile non-template files (`EEx.compile_file/1`, `Code.eval_quoted/1`)
   `Vox.Builder.FileCompiler`
3. put compiled files into template files (`EEx.eval_file/2`)
   `Vox.Builder.Templater`
4. save file contents to the correct path

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `vox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vox, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/vox>.
