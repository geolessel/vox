defmodule Vox.Builder.FileWriter do
  import Mix.Shell.IO, only: [info: 1]

  import Mix.Generator,
    only: [copy_file: 3, create_directory: 2, create_file: 3]

  alias Vox.Builder

  def write(%Builder{clean: clean} = _opts) do
    {:ok, output_dir} = Path.safe_relative(Application.get_env(:vox, :output_dir))

    if String.starts_with?(output_dir, "/") || String.starts_with?(output_dir, ".."),
      do: raise("For safety reasons, your output dir can't start with `/` or `..`")

    if clean do
      {:ok, removed} = File.rm_rf(output_dir)
      Enum.each(removed, &report_deleted/1)
    end

    Mix.Generator.create_directory(output_dir)

    files = Vox.Builder.Collection.list_files()

    # TODO Clean this up A LOT
    files_by_type =
      Enum.reduce(files, %{}, fn %{type: type} = file, acc ->
        Map.update(acc, type, [file], &[file | &1])
      end)

    files_by_type
    |> Map.get(:evaled, [])
    |> Enum.each(fn %{destination_path: path, final: html} ->
      dirname = Path.join([output_dir, Path.dirname(path)])
      create_directory(dirname, quiet: true)

      filename = Path.basename(path)

      path = Path.join([dirname, filename])
      create_file(path, html, force: true)
    end)

    files_by_type
    |> Map.get(:passthrough, [])
    |> Enum.each(fn %{source_path: source_path, destination_path: destination_path} ->
      dirname = Path.join([output_dir, Path.dirname(destination_path)])
      create_directory(dirname, quiet: true)

      filename = Path.basename(destination_path)

      path = Path.join([dirname, filename])
      copy_file(source_path, path, force: true)
    end)
  end

  defp report_deleted(path),
    do: info(IO.ANSI.red() <> "* deleted" <> IO.ANSI.reset() <> " " <> path)
end
