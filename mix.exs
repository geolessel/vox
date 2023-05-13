defmodule Vox.MixProject do
  use Mix.Project

  def project do
    [
      app: :vox,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:plug, "~> 1.14.2"},
      {:bandit, "~> 0.6"},
      {:file_system, "~> 0.2"}
    ]
  end

  defp package do
    %{
      description: "Static site builder for Elixir lovers",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/geolessel/vox"}
    }
  end
end
