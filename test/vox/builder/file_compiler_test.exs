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

  describe "compute_bindings/1" do
    test "puts a file's bindings accessible by dot syntax" do
      [source] =
        [%Vox.Builder.File{source_path: "test/support/posts/01-hello-world.html.eex"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()

      assert source.title == "Hello world"
      assert source.date == ~D[2023-04-16]
      assert source.author.name == "Geoffrey Lessel"
      assert source.author.site == "https://builditwithphoenix.com"
      assert source.collections == [:posts]
    end
  end

  describe "eval_files/1" do
    test "changes nothing for passthrough files" do
      before =
        [%Vox.Builder.File{source_path: "test/support/assets/style.css"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()

      assert before == FileCompiler.eval_files(before)
    end

    test "stores HTML output in `content`" do
      [source] =
        [%Vox.Builder.File{source_path: "test/support/posts/01-hello-world.html.eex"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()

      assert String.starts_with?(source.content, "<h1>Hello, world</h1>")
    end

    test "replaces assigns with real values" do
      raw_contents = File.read!("test/support/posts/01-hello-world.html.eex")

      [evaled] =
        [%Vox.Builder.File{source_path: "test/support/posts/01-hello-world.html.eex"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()

      assert String.contains?(raw_contents, "written by <%= @author[:name] %>")
      assert String.contains?(evaled.content, "written by Geoffrey Lessel")
      refute String.contains?(evaled.content, "<%= @")
    end
  end

  describe "put_nearest_template/1" do
    test "changes nothing for passthrough files" do
      style = %Vox.Builder.File{type: :passthrough}
      assert [style] == FileCompiler.put_nearest_template([style])
    end

    test "sets the template if specified in the bindings" do
      [custom_template] =
        [%Vox.Builder.File{source_path: "test/support/posts/work/03-awesome-thing.html.eex"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()
        |> FileCompiler.put_nearest_template()

      assert custom_template.template == "test/support/posts/work/_specified_template.html.eex"
    end

    test "finds the template in a shared subdirectory" do
      [subdirectory_template] =
        [%Vox.Builder.File{source_path: "test/support/posts/work/04-find-my-template.html.eex"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()
        |> FileCompiler.put_nearest_template()

      assert subdirectory_template.template == "test/support/posts/work/_template.html.eex"
    end

    test "finds the template in the root directory if no other subdirectory has a template" do
      [root_template] =
        [%Vox.Builder.File{source_path: "test/support/posts/confs/elixir/2023/05-vox.html.eex"}]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()
        |> FileCompiler.put_nearest_template()

      assert root_template.template == "test/support/_template.html.eex"
    end
  end

  describe "insert_into_template/1" do
    test "changes nothing for passthrough files" do
      style = %Vox.Builder.File{type: :passthrough}
      assert [style] == FileCompiler.insert_into_template([style])
    end

    test "inserts the file content into its template" do
      [evaled] =
        [
          %Vox.Builder.File{
            root_template: "test/support/_root.html.eex",
            source_path: "test/support/posts/work/04-find-my-template.html.eex"
          }
        ]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()
        |> FileCompiler.put_nearest_template()
        |> FileCompiler.insert_into_template()

      assert String.contains?(evaled.final, "<div id=\"you-will-never-find-me\">")
    end

    test "inserts the file content into the root template" do
      [evaled] =
        [
          %Vox.Builder.File{
            root_template: "test/support/_root.html.eex",
            source_path: "test/support/posts/work/04-find-my-template.html.eex"
          }
        ]
        |> FileCompiler.compile_files()
        |> FileCompiler.compute_collections()
        |> FileCompiler.compute_bindings()
        |> FileCompiler.update_collector()
        |> FileCompiler.eval_files()
        |> FileCompiler.put_nearest_template()
        |> FileCompiler.insert_into_template()

      assert String.contains?(evaled.final, "<body id=\"root\">")
    end
  end
end
