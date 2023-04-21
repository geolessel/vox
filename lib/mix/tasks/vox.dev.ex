defmodule Mix.Tasks.Vox.Dev do
  @shortdoc "Start and run the dev server"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")
    Process.sleep(:infinity)
  end
end
