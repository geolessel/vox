Code.require_file("mix_helper.exs", __DIR__)

defmodule VoxNewTest do
  use ExUnit.Case
  import MixHelper
  import ExUnit.CaptureIO

  @app_name "blog"

  test "returns the version" do
    Mix.Tasks.Vox.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Vox installer v" <> _]}
  end

  test "new with defaults" do
    in_tmp("new with defaults", fn ->
      Mix.Tasks.Vox.New.run([@app_name])

      assert_file("#{@app_name}/mix.exs", fn file ->
        assert file =~ "defmodule Blog.MixProject"
        assert file =~ "app: :blog"
        refute file =~ "mod: {Blog.Application, []}"
        refute file =~ ":esbuild"
      end)

      assert_file("#{@app_name}/config/config.exs", fn file ->
        assert file =~ "src_dir = \"site\""
        assert file =~ "output_dir = \"_html\""
        refute file =~ "config :esbuild"
      end)

      refute_file("#{@app_name}/assets/app.js")
      refute_file("#{@app_name}/lib/application.ex")
      refute_file("#{@app_name}/lib/#{@app_name}/esbuild.ex")
    end)
  end

  test "new with --esbuild" do
    in_tmp("new with --esbuild", fn ->
      Mix.Tasks.Vox.New.run([@app_name, "--esbuild"])

      shared_file_assertions()

      assert_file("#{@app_name}/mix.exs", fn file ->
        assert file =~ "defmodule Blog.MixProject"
        assert file =~ "app: :blog"
        assert file =~ "mod: {Blog.Application, []}"
        assert file =~ ":esbuild"
      end)

      assert_file("#{@app_name}/config/config.exs", fn file ->
        assert file =~ "src_dir = \"site\""
        assert file =~ "output_dir = \"_html\""
        assert file =~ "config :esbuild"
      end)

      assert_file("#{@app_name}/assets/app.js")
      assert_file("#{@app_name}/lib/application.ex")
      assert_file("#{@app_name}/lib/#{@app_name}/esbuild.ex")
    end)
  end

  test "new without args" do
    in_tmp("new without args", fn ->
      assert capture_io(fn -> Mix.Tasks.Vox.New.run([]) end) =~
               "Generate a new Vox application."
    end)
  end

  def shared_file_assertions() do
    assert_file("#{@app_name}/README.md")
    assert_file("#{@app_name}/lib/#{@app_name}.ex")
    assert_file("#{@app_name}/site/_root.html.eex")
    assert_file("#{@app_name}/site/_template.html.eex")
    assert_file("#{@app_name}/site/index.html.eex")
    assert_file("#{@app_name}/site/posts/hello-world.html.eex")
    assert_file("#{@app_name}/test/test_helper.exs")
    assert_file("#{@app_name}/test/#{@app_name}_test.exs")
  end
end
