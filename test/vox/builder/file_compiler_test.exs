defmodule Vox.Builder.FileCompilerTest do
  use ExUnit.Case, async: true

  alias Vox.Builder.FileCompiler

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
end
