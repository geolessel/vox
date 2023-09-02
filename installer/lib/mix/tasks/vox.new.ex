defmodule Mix.Tasks.Vox.New do
  @shortdoc "Generate a new Vox application"

  @template_string_to_replace "APP"

  use Mix.Task
  use VoxNew.Templater

  alias VoxNew.Project

  template("mix.exs")
  template("README.md")
  template("config/config.exs")
  template("lib/#{@template_string_to_replace}.ex")
  template("site/_root.html.eex")
  template("site/_template.html.eex")
  template("site/index.html.eex")
  template("site/posts/hello-world.html.eex")
  template("test/test_helper.exs")
  template("test/#{@template_string_to_replace}_test.exs")

  @impl Mix.Task
  def run(argv) do
    {_parse, [path | _rest], _invalid} = OptionParser.parse(argv, strict: [])

    # [TODO] I think these could result in incorrect formatting
    module_name = Macro.camelize(path)
    app_name = Macro.underscore(path)

    generate(%Project{app_name: app_name, module_name: module_name, base_path: path})
  end

  defp generate(project) do
    project
    |> copy_templates()
  end

  defp copy_templates(%Project{base_path: base_path} = project) do
    @templates
    |> Enum.each(fn template ->
      contents = render_template(template, project: project)

      template_for_app =
        String.replace(template, @template_string_to_replace, project.app_name)

      write_path = Path.join(base_path, template_for_app)
      Mix.Generator.create_file(write_path, contents)
    end)

    project
  end
end
