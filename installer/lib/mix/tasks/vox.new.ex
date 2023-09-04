defmodule Mix.Tasks.Vox.New do
  @shortdoc "Generate a new Vox application"

  @template_string_to_replace "APP"

  use Mix.Task
  use VoxNew.Templater

  alias VoxNew.Project

  template("mix.exs")
  template("README.md")
  template("assets/app.js", :esbuild)
  template("config/config.exs")
  template("lib/application.ex", :esbuild)
  template("lib/#{@template_string_to_replace}/esbuild.ex", :esbuild)
  template("lib/#{@template_string_to_replace}.ex")
  template("site/_root.html.eex")
  template("site/_template.html.eex")
  template("site/index.html.eex")
  template("site/posts/hello-world.html.eex")
  template("test/test_helper.exs")
  template("test/#{@template_string_to_replace}_test.exs")

  @impl Mix.Task
  def run(argv) do
    {flags, [path | _rest]} = OptionParser.parse!(argv, strict: [esbuild: :boolean])

    # [TODO] I think these could result in incorrect formatting
    module_name = Macro.camelize(path)
    app_name = Macro.underscore(path)
    esbuild = Keyword.get(flags, :esbuild, false)

    generate(%Project{
      app_name: app_name,
      base_path: path,
      esbuild: esbuild,
      module_name: module_name
    })
  end

  defp generate(project) do
    project
    |> copy_templates()
  end

  defp copy_templates(%Project{} = project) do
    @templates
    |> Enum.each(fn
      {template, true} ->
        copy_template(template, project)

      {template, flag} when is_atom(flag) ->
        if Map.get(project, flag) do
          copy_template(template, project)
        end
    end)

    project
  end

  defp copy_template(template, %Project{base_path: base_path} = project) do
    contents = render_template(template, project: project)

    template_for_app =
      String.replace(template, @template_string_to_replace, project.app_name)

    write_path = Path.join(base_path, template_for_app)
    Mix.Generator.create_file(write_path, contents)
  end
end
