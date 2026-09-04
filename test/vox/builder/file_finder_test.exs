defmodule Vox.Builder.FileFinderTest do
  # These tests read the global `Vox.Builder.Collection` state, which the
  # async `Vox.Builder.FileCompilerTest` tests also write to (via
  # `FileCompiler.update_collector/1`). Running sync here avoids racing
  # those tests, since ExUnit runs all async modules to completion before
  # any sync module starts.
  use ExUnit.Case, async: false

  alias Vox.Builder.FileFinder

  setup do
    Vox.Builder.Collection.empty()
    :ok
  end

  describe "collect/1" do
    test "adds all non-private files in the given directory and subdirectories to the Collection" do
      expected =
        "test/support/**/*"
        |> Path.wildcard()
        |> Enum.reject(&File.dir?/1)
        |> Enum.reject(fn path ->
          relative = Path.relative_to(path, "test/support")
          segments = Path.split(relative)

          String.starts_with?(List.last(segments), "_") or "partials" in segments
        end)
        |> Enum.sort()

      FileFinder.collect("test/support")

      actual =
        Vox.Builder.Collection.list_files()
        |> Enum.map(& &1.source_path)
        |> Enum.sort()

      assert actual == expected
    end

    test "excludes underscore-prefixed files and partials directories explicitly" do
      FileFinder.collect("test/support")

      actual =
        Vox.Builder.Collection.list_files()
        |> Enum.map(& &1.source_path)

      refute "test/support/_root.html.eex" in actual
      refute "test/support/posts/work/_template.html.eex" in actual
      refute "test/support/partials/with-assigns.html.eex" in actual
      refute "test/support/partials/without-assigns.html.eex" in actual

      assert "test/support/posts/01-hello-world.html.eex" in actual
      assert "test/support/assets/style.css" in actual
      assert "test/support/templates/root.html.eex" in actual
    end
  end
end
