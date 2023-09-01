defmodule Vox.Dev.Watcher do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(dirs: dirs, opts: opts) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: dirs)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid, opts: opts}}
  end

  def handle_info(
        {:file_event, watcher_pid, {_path, _events}},
        %{watcher_pid: watcher_pid} = state
      ) do
    Vox.Builder.build(state.opts)
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end
end
