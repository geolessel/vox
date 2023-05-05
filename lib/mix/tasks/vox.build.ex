defmodule Mix.Tasks.Vox.Build do
  @shortdoc "Build a site with HTML"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    # Vox.Compiler.compile()
    Vox.Builder.build()
  end
end
