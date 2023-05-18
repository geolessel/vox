defmodule Mix.Tasks.Vox.Build do
  @shortdoc "Build a site with HTML"

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Vox.Builder.build()
  end
end
