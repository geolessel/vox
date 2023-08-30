defmodule Mix.Tasks.Vox.New do
  @shortdoc "Generate a new Vox application"

  use Mix.Task
  use VoxNew.Templater

  template("site/_root.html.eex")
  template("site/_template.html.eex")
  template("site/index.html.eex")
  template("site/posts/hello-world.html.eex")
  template("config/config.exs")

  @impl Mix.Task
  def run(argv) do
    {_parse, [path | _rest], _invalid} = OptionParser.parse(argv, strict: [])

    generate(path)
  end

  defp generate(base_path) do
    base_path
    |> run_mix_new()
    |> inject_deps()
    |> create_directories()
    |> copy_templates()
  end

  defp run_mix_new(base_path) do
    Mix.shell().cmd("mix new #{base_path}")
    base_path
  end

  defp inject_deps(base_path) do
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
    base_path
  end

  defp create_directories(base_path) do
    @templates
    |> Enum.map(&Path.dirname(Path.join(base_path, &1)))
    |> Enum.uniq()
    |> Enum.each(&Mix.Generator.create_directory/1)

    base_path
  end

  defp copy_templates(base_path) do
    @templates
    |> Enum.each(fn template ->
      write_path = Path.join(base_path, template)
      contents = render_template(template, app_name: String.capitalize(base_path))
      Mix.Generator.create_file(write_path, contents)
    end)
  end
end
