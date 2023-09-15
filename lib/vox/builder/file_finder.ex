defmodule Vox.Builder.FileFinder do
  def collect(root_dir) do
    root_dir
    |> find()
    |> Enum.each(&Vox.Builder.Collection.add(&1, :unprocessed))
  end

  def find(root_dir) do
    [root_dir, "**", "*"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.reject(&File.dir?/1)
  end
end
