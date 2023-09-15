defmodule Vox.Builder.FileCompilerTest do
  use ExUnit.Case, async: true

  alias Vox.Builder.FileCompiler

  setup_all do
    Application.put_env(:vox, :src_dir, "test/support")
    Application.put_env(:vox, :destination_dir, "_html")
  end

  describe "extract_frontmatter/1" do
    test "extracts front matter when there is some" do
      files = [%Vox.Builder.File{source_path: "test/support/posts/01-hello-world.html.eex"}]

      [%Vox.Builder.File{frontmatter: frontmatter}] = FileCompiler.extract_frontmatter(files)

      assert frontmatter.title == "Hello world"
      assert frontmatter.date == ~D[2023-04-16]
      assert frontmatter.author.name == "Geoffrey Lessel"
      assert frontmatter.author.site == "https://builditwithphoenix.com"
    end

    test "does not fail when there is no front matter" do
      files = [%Vox.Builder.File{source_path: "test/support/templates/root.html.eex"}]
      [%Vox.Builder.File{frontmatter: frontmatter}] = FileCompiler.extract_frontmatter(files)

      assert frontmatter == %{}
    end
  end

  describe "compile_files/1 for files with unknown extensions" do
    setup do
      [source] =
        [%Vox.Builder.File{source_path: "test/support/assets/style.css"}]
        |> FileCompiler.compile_files()

      %{source: source}
    end

    test "declares them passthrough files", %{source: source} do
      assert source.type == :passthrough
    end

    test "puts destination_path", %{source: source} do
      assert source.destination_path == "/assets/style.css"
    end

    test "leaves the compiled attribute empty", %{source: source} do
      assert source.compiled == nil
    end
  end

  describe "compile_files/1 for files with eex extensions" do
    setup do
      [source] =
        [%Vox.Builder.File{source_path: "test/support/posts/01-hello-world.html.eex"}]
        |> FileCompiler.compile_files()

      %{source: source}
    end

    test "compiles the file with EEx", %{source: source} do
      assert {:__block__, _, _} = source.compiled
    end

    test "puts the destination path", %{source: source} do
      assert source.destination_path == "/posts/01-hello-world.html"
    end

    test "declares them evaled files", %{source: source} do
      assert source.type == :evaled
    end
  end

  describe "compute_collections/1" do
    setup do
      files =
        [
          %Vox.Builder.File{source_path: "test/support/posts/01-hello-world.html.eex"},
          %Vox.Builder.File{source_path: "test/support/posts/02-you-there?.html.eex"}
        ]
        |> FileCompiler.compile_files()

      %{files: files}
    end

    test "each File knows about which collections it belongs to", %{files: files} do
      [you_there, hello_world] = FileCompiler.compute_collections(files)

      assert hello_world.destination_path == "/posts/01-hello-world.html"
      assert hello_world.collections == [:posts]
      assert you_there.destination_path == "/posts/02-you-there?.html"
      assert you_there.collections == [:tag1, :tag2]
    end
  end
end
