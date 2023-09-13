defmodule Vox.Builder.FileFinder do
  @spec collect(binary()) :: :ok
  def collect(root_dir) do
    root_dir
    |> find()
    |> Enum.each(&Vox.Builder.Collection.add(&1, :unprocessed))
  end

  @spec find(binary()) :: [binary]
  def find(root_dir) do
    [root_dir, "**", "*"]
    |> Path.join()
    |> Path.wildcard()
  end
end
