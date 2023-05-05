defmodule Vox.Builder.FileCompiler do
  defmodule File do
    defstruct content: "",
              destination_path: "",
              final: "",
              source_path: "",
              compiled: nil,
              bindings: []
  end

  @spec compile() :: []
  def compile() do
    Vox.Builder.Collection.list_files()
    |> compile_files()
    |> compute_bindings()
    |> add_to_collection(:compiled)
    |> eval_files()
    |> add_to_collection(:evaled)
    |> template()
    |> add_to_collection(:final)
  end

  def compile_files(paths) do
    Enum.map(paths, fn path ->
      compiled = EEx.compile_file(path)

      destination_path =
        path
        # TODO: handle non-.eex files
        |> Path.rootname(".eex")
        |> String.trim_leading(Application.get_env(:vox, :src_dir) <> "/")

      %File{
        compiled: compiled,
        source_path: path,
        destination_path: destination_path
      }
    end)
  end

  def compute_bindings(files) do
    Enum.map(files, fn file ->
      {_content, bindings} =
        Code.eval_quoted(file.compiled, [assigns: [collection: Vox.Builder.Collection]], __ENV__)

      %{file | bindings: bindings}
    end)
  end

  def add_to_collection(files, type) when type in [:compiled, :evaled, :final] do
    Enum.each(files, &Vox.Builder.Collection.add(&1, type))
    files
  end

  def eval_files(files) do
    Enum.map(files, fn %File{compiled: compiled} = file ->
      {content, _bindings} =
        Code.eval_quoted(compiled, [assigns: [collection: Vox.Builder.Collection]], __ENV__)

      %{file | content: content}
    end)
  end

  def template(files) do
    Enum.map(files, fn %File{content: content} = file ->
      assigns =
        file.bindings
        |> Enum.filter(fn
          {{_, EEx.Engine}, _} -> false
          _ -> true
        end)
        |> Enum.into(Keyword.new())
        |> Keyword.merge(inner_content: file.content)

      final = EEx.eval_file("site/_template.html.eex", assigns: assigns)
      %{file | final: final}
    end)
  end
end
