defmodule <%= @project.module_name %>.MixProject do
  use Mix.Project

  def project do
    [
      app: :<%= @project.app_name %>,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [<%= if @project.esbuild do %>
      mod: {<%= @project.module_name %>.Application, []},<% end %>
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [<%= if @project.esbuild do %>
      {:esbuild, "~> 0.7.1"},<% end %>
      {:vox, "~> <%= @project.vox_version %>"}
    ]
  end
end
