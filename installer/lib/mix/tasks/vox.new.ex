defmodule Mix.Tasks.Vox.New do
  @shortdoc "Generate a new Vox application"
  @moduledoc """
  Generate a new Vox application.

  Scaffolds a simple website using Vox.

  The app and module names are derived from the name of the target
  directory (the last segment of the expanded path), so `mix vox.new
  nested/dir/blog` and `mix vox.new blog` both produce an app named
  `blog`.

  ## Command line options

      * `--esbuild` - include a simple esbuild system for asset compliation

      * `-v`, `--version` - prints the Vox installer version
  """

  @template_string_to_replace "APP"
  @version Mix.Project.config()[:version]

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
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("Vox installer v#{@version}")
  end

  def run(argv) do
    case OptionParser.parse!(argv, strict: [esbuild: :boolean]) do
      {_, []} ->
        Mix.Tasks.Help.run(["vox.new"])

      {flags, [path | _rest]} ->
        base_name = path |> Path.expand() |> Path.basename()
        app_name = Macro.underscore(base_name)
        module_name = Macro.camelize(base_name)
        esbuild = Keyword.get(flags, :esbuild, false)

        generate(%Project{
          app_name: app_name,
          base_path: path,
          esbuild: esbuild,
          module_name: module_name
        })
    end
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
