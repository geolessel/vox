defmodule VoxNew.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/geolessel/vox"

  def project do
    [
      app: :vox_new,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      package: package(),
      deps: deps(),
      docs: docs(),
      description: """
      Vox static site project generator.

      Provides a `mix vox.new` task to bootstrap a new Elixir application
      with Vox dependencies and a basic template to generate.
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:eex, :logger]
    ]
  end

  defp package do
    [
      name: :vox_new,
      files: ["lib", "templates", "mix.exs", "README.md"],
      maintainers: ["Geoffrey Lessel"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.30.6", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Mix.Tasks.Vox.New"
    ]
  end
end
