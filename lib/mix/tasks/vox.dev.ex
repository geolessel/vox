defmodule Mix.Tasks.Vox.Dev do
  @shortdoc "Start and run the dev server"
  @src_dir Application.compile_env(:vox, :src_dir)

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Vox.Builder.start()
    Vox.Builder.build()

    Supervisor.start_link([{Bandit, plug: Vox.Dev.Server}],
      strategy: :one_for_one,
      name: Vox.Supervisor
    )

    Vox.Dev.Watcher.start_link(dirs: ["lib", @src_dir])

    Process.sleep(:infinity)
  end
end
