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

      assert_file("#{@app_name}/README.md")
      assert_file("#{@app_name}/config/config.exs")
      assert_file("#{@app_name}/lib/#{@app_name}.ex")
      assert_file("#{@app_name}/site/_root.html.eex")
      assert_file("#{@app_name}/site/_template.html.eex")
      assert_file("#{@app_name}/site/index.html.eex")
      assert_file("#{@app_name}/site/posts/hello-world.html.eex")
      assert_file("#{@app_name}/test/test_helper.exs")
      assert_file("#{@app_name}/test/#{@app_name}_test.exs")

      assert_file("#{@app_name}/mix.exs", fn file ->
        assert file =~ "app: :blog"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
      end)

      refute_file("#{@app_name}/assets/app.js")
      refute_file("#{@app_name}/lib/application.ex")
      refute_file("#{@app_name}/lib/#{@app_name}/esbuild.ex")
    end)
  end

  test "new with --esbuild" do
    in_tmp("new with --esbuild", fn ->
      Mix.Tasks.Vox.New.run([@app_name, "--esbuild"])

      assert_file("#{@app_name}/README.md")
      assert_file("#{@app_name}/config/config.exs")
      assert_file("#{@app_name}/lib/#{@app_name}.ex")
      assert_file("#{@app_name}/site/_root.html.eex")
      assert_file("#{@app_name}/site/_template.html.eex")
      assert_file("#{@app_name}/site/index.html.eex")
      assert_file("#{@app_name}/site/posts/hello-world.html.eex")
      assert_file("#{@app_name}/test/test_helper.exs")
      assert_file("#{@app_name}/test/#{@app_name}_test.exs")

      assert_file("#{@app_name}/mix.exs", fn file ->
        assert file =~ "app: :blog"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
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
end
