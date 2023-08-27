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
      {:plug, "~> 1.14.2"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_live_reload, "~> 0.1"},
      {:file_system, "~> 0.2"},
      {:mime, "~> 2.0.5"}
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
