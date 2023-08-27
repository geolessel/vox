defmodule Mix.Tasks.Vox.Dev do
  @shortdoc "Start and run the dev server"
  @src_dir Application.compile_env(:vox, :src_dir)
  @output_dir Application.compile_env(:vox, :output_dir)

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Vox.Builder.start()
    Vox.Builder.build()

    configure_live_browser_reloading()
    start_file_watcher()
    start_server()

    Process.sleep(:infinity)
  end

  defp configure_live_browser_reloading,
    do: Application.put_env(:plug_live_reload, :patterns, [~r"#{@output_dir}/*"])

  defp start_file_watcher, do: Vox.Dev.Watcher.start_link(dirs: ["lib", @src_dir])

  defp start_server do
    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug: Vox.Dev.Server,
       options: [
         port: 4000,
         dispatch: dispatch()
       ]}
    ]

    opts = [strategy: :one_for_one, name: Vox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch(),
    do: [
      {:_,
       [
         {"/plug_live_reload/socket", PlugLiveReload.Socket, []},
         {:_, Plug.Cowboy.Handler, {Vox.Dev.Server, []}}
       ]}
    ]
end
