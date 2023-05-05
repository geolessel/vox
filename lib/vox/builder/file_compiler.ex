defmodule Vox.Builder.FileCompiler do
  require Logger

  defmodule File do
    defstruct bindings: [],
              compiled: nil,
              content: "",
              destination_path: "",
              final: "",
              source_path: "",
              template: ""
  end

  @spec compile() :: []
  def compile() do
    Vox.Builder.Collection.list_files()
    |> compile_files()
    |> compute_bindings()
    |> add_to_collection(:compiled)
    |> eval_files()
    |> add_to_collection(:evaled)
    |> put_nearest_template()
    |> insert_into_template()
    |> add_to_collection(:final)
  end

  defp compile_files(paths) do
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

  defp compute_bindings(files) do
    Enum.map(files, fn file ->
      {_content, bindings} =
        Code.eval_quoted(file.compiled, [assigns: [collection: Vox.Builder.Collection]], __ENV__)

      %{file | bindings: bindings}
    end)
  end

  defp add_to_collection(files, type) when type in [:compiled, :evaled, :final] do
    Enum.each(files, &Vox.Builder.Collection.add(&1, type))
    files
  end

  defp eval_files(files) do
    Enum.map(files, fn %File{compiled: compiled} = file ->
      {content, _bindings} =
        Code.eval_quoted(compiled, [assigns: [collection: Vox.Builder.Collection]], __ENV__)

      %{file | content: String.trim(content)}
    end)
  end

  defp insert_into_template(files) do
    Enum.map(files, fn %File{content: content, template: template} = file ->
      assigns =
        file.bindings
        |> Enum.filter(fn
          {{_, EEx.Engine}, _} -> false
          _ -> true
        end)
        |> Enum.into(Keyword.new())
        |> Keyword.merge(inner_content: content)

      final = EEx.eval_file(template, assigns: assigns)
      %{file | final: final}
    end)
  end

  def put_nearest_template(files) when is_list(files) do
    Enum.map(files, &put_nearest_template/1)
  end

  def put_nearest_template(%File{source_path: path, bindings: bindings} = file) do
    template =
      case bindings[:template] do
        nil ->
          find_template_in_this_and_parent_directory({:ok, Path.dirname(path)})

        template ->
          {:ok, template} = Path.safe_relative(Path.join(Path.dirname(path), template))
          template
      end

    %{file | template: template}
  end

  defp find_template_in_this_and_parent_directory(:error), do: "site/_template.html.eex"

  defp find_template_in_this_and_parent_directory({:ok, path}) do
    this_template = Path.join([path, "_template.html.eex"])

    case Elixir.File.exists?(this_template) do
      true ->
        this_template

      false ->
        parent_dir = Path.safe_relative(Path.join(path, ".."))
        find_template_in_this_and_parent_directory(parent_dir)
    end
  end
end
