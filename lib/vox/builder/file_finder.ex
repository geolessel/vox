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
  end
end
