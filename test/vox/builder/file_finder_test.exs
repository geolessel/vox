defmodule Vox.Builder.FileFinderTest do
  use ExUnit.Case, async: true

  alias Vox.Builder.FileFinder

  describe "collect/1" do
    test "adds all files in the given directory and subdirectories to the Collection" do
      expected =
        "test/support/**/*"
        |> Path.wildcard()
        |> Enum.reject(&File.dir?/1)
        |> Enum.sort()

      FileFinder.collect("test/support")

      actual =
        Vox.Builder.Collection.list_files()
        |> Enum.map(& &1.source_path)
        |> Enum.sort()

      assert actual == expected
    end
  end
end
