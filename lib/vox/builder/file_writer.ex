defmodule Vox.Builder.FileWriter do
  require Logger

  def write() do
    {:ok, output_dir} = Path.safe_relative(Application.get_env(:vox, :output_dir))

    if String.starts_with?(output_dir, "/") || String.starts_with?(output_dir, ".."),
      do: raise("For safety reasons, your output dir can't start with `/` or `..`")

    Logger.info("Deleting output directory (#{output_dir})...")
    {:ok, removed} = File.rm_rf(output_dir)
    Enum.each(removed, fn path -> Logger.debug("  deleted #{path}") end)

    Logger.info("Creating output directory (#{output_dir})...")
    File.mkdir_p!(output_dir)

    Logger.info("Saving files...")

    files = Vox.Builder.Collection.list_files()

    # TODO Clean this up A LOT
    files_by_type =
      Enum.reduce(files, %{}, fn %{type: type} = file, acc ->
        Map.update(acc, type, [file], &[file | &1])
      end)

    files_by_type.evaled
    |> Enum.each(fn %{destination_path: path, final: html} ->
      dirname = Path.join([output_dir, Path.dirname(path)])
      Logger.debug("  creating directory: #{dirname}")
      File.mkdir_p!(dirname)

      filename = Path.basename(path)

      path = Path.join([dirname, filename])
      Logger.debug("  saving file: #{path}")

      File.open(path, [:write], fn file ->
        IO.write(file, html)
      end)
    end)

    files_by_type.passthrough
    |> Enum.each(fn %{source_path: source_path, destination_path: destination_path} ->
      dirname = Path.join([output_dir, Path.dirname(destination_path)])
      Logger.debug("  creating directory: #{dirname}")
      File.mkdir_p!(dirname)

      filename = Path.basename(destination_path)

      path = Path.join([dirname, filename])
      Logger.debug("  saving file: #{path}")

      File.cp!(source_path, path)
    end)
  end
end
