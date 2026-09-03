defmodule Vox.Builder.FileFinder do
  @spec collect(binary()) :: :ok
  def collect(root_dir) do
    root_dir
    |> find()
    |> Enum.each(&Vox.Builder.Collection.add(&1, :unprocessed))
  end

  @spec find(binary()) :: [binary]
  defp find(root_dir) do
    [root_dir, "**", "*"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.reject(&File.dir?/1)
    |> Enum.reject(fn path ->
      path
      |> Path.relative_to(root_dir)
      |> private?()
    end)
  end

  @spec private?(binary()) :: boolean()
  defp private?(relative_path) do
    segments = Path.split(relative_path)

    String.starts_with?(List.last(segments), "_") or "partials" in segments
  end
end
