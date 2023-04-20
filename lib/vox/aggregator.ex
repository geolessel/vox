defmodule Vox.Aggregator do
  @allowed_extensions ["eex"]

  @spec find_posts(root_dir :: binary) :: [binary]
  def find_posts(root_dir) do
    extensions = Enum.join(@allowed_extensions, ",")

    [root_dir, "**", "*.{#{extensions}}"]
    |> Path.join()
    |> Path.wildcard()
  end
end
