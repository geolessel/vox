defmodule Mix.Tasks.Vox.New do
  @shortdoc "Generate a new Vox application"

  use Mix.Task
  use VoxNew.Templater

  alias VoxNew.Project

  template("site/_root.html.eex")
  template("site/_template.html.eex")
  template("site/index.html.eex")
  template("site/posts/hello-world.html.eex")
  template("config/config.exs")

  @impl Mix.Task
  def run(argv) do
    {_parse, [path | _rest], _invalid} = OptionParser.parse(argv, strict: [])

    generate(%Project{app_name: Macro.camelize(path), base_path: path})
  end

  defp generate(project) do
    project
    |> run_mix_new()
    |> inject_deps()
    |> create_directories()
    |> copy_templates()
  end

  defp run_mix_new(%Project{base_path: base_path} = project) do
    Mix.shell().cmd("mix new #{base_path}")
    project
  end

  defp inject_deps(%Project{base_path: base_path} = project) do
    string_to_split_on = """
      defp deps do
        [
    """

    mix_path = Path.join(base_path, "mix.exs")

    mix_contents = File.read!(mix_path)

    [pre, post] = String.split(mix_contents, string_to_split_on)

    mix_contents =
      pre
      |> Kernel.<>(string_to_split_on)
      |> Kernel.<>("      {:vox, \"~> 0.1\"},\n")
      |> Kernel.<>(post)

    File.write!(mix_path, mix_contents)

    project
  end

  defp create_directories(%Project{base_path: base_path} = project) do
    @templates
    |> Enum.map(&Path.dirname(Path.join(base_path, &1)))
    |> Enum.uniq()
    |> Enum.each(&Mix.Generator.create_directory/1)

    project
  end

  defp copy_templates(%Project{app_name: app_name, base_path: base_path} = project) do
    @templates
    |> Enum.each(fn template ->
      write_path = Path.join(base_path, template)
      contents = render_template(template, app_name: app_name)
      Mix.Generator.create_file(write_path, contents)
    end)

    project
  end
end
