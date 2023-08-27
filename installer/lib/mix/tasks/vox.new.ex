defmodule Mix.Tasks.Vox.New do
  @shortdoc "Generate a new Vox application"

  use Mix.Task

  @impl Mix.Task
  def run(argv) do
    {_parse, [path | _rest], _invalid} = OptionParser.parse(argv, strict: [])

    # TODO better error handling
    # if File.dir?(path), do: Mix.raise("Directory already exists: #{path}")

    generate(path)
  end

  defp generate(base_path) do
    base_path
    |> run_mix_new()
    |> inject_deps()
    |> create_directories()
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
    Mix.Generator.create_directory(Path.join([base_path, "site"]))
    base_path
  end
end
