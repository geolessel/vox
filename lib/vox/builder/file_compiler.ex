defmodule Vox.Builder.FileCompiler do
  require Logger

  alias Vox.Builder.File

  @spec compile() :: []
  def compile() do
    Vox.Builder.Collection.list_files()
    |> compile_files()
    |> compute_collections()
    |> compute_bindings()
    |> update_collector()
    |> eval_files()
    |> put_nearest_template()
    |> insert_into_template()
    |> update_collector()
  end

  defp compile_files(files) do
    Enum.reduce(files, [], fn %File{source_path: path} = file, acc ->
      case Path.extname(path) do
        # TODO: handle non-.eex evaled files
        ".eex" ->
          compiled = EEx.compile_file(path)

          destination_path =
            path
            |> Path.rootname(".eex")
            |> String.trim_leading(Application.get_env(:vox, :src_dir) <> "/")

          [
            %File{
              file
              | compiled: compiled,
                destination_path: destination_path,
                type: :evaled
            }
            | acc
          ]

        "" ->
          acc

        _ext_of_passthrough ->
          destination_path = String.trim_leading(path, Application.get_env(:vox, :src_dir) <> "/")
          [%File{file | destination_path: destination_path, type: :passthrough} | acc]
      end
    end)
  end

  defp compute_collections(files) do
    Enum.map(files, fn file ->
      collections =
        file.compiled
        |> Macro.prewalker()
        |> Enum.map(& &1)
        |> Enum.reduce([], fn
          {:=, _line, [{:collections, _collections_line, _nil}, collections]}, acc ->
            collections = List.wrap(collections)
            Vox.Builder.Collection.add_collections(collections)
            collections ++ acc

          _other, acc ->
            acc
        end)

      %{file | collections: collections}
    end)
  end

  def partial(partial_path, assigns) do
    file_path = Path.join(Application.get_env(:vox, :src_dir), partial_path)
    EEx.eval_file(file_path, assigns: assigns)
  end

  defp compute_bindings(files) do
    # for the __ENV__ later on
    require Vox

    Enum.map(files, fn file ->
      {_content, bindings} =
        Code.eval_quoted(
          file.compiled,
          [assigns: Vox.Builder.Collection.assigns()],
          __ENV__
        )

      %{file | bindings: bindings}
    end)
  end

  defp update_collector(files) do
    Vox.Builder.Collection.update_files(files)
    files
  end

  defp add_to_collection(files, type) when type in [:compiled, :evaled, :final] do
    Enum.each(files, &Vox.Builder.Collection.add(&1, type))
    files
  end

  defp eval_files(files) do
    Enum.map(files, fn
      %File{type: :passthrough} = file ->
        file

      %File{compiled: compiled, type: :evaled} = file ->
        {content, _bindings} =
          Code.eval_quoted(
            compiled,
            [assigns: Vox.Builder.Collection.assigns() ++ file.bindings],
            __ENV__
          )

        %{file | content: String.trim(content)}
    end)
  end

  defp insert_into_template(files) do
    Enum.map(files, fn
      %File{type: :passthrough} = file ->
        file

      %File{content: content, template: template} = file ->
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

  def put_nearest_template(%File{type: :passthrough} = file), do: file

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
