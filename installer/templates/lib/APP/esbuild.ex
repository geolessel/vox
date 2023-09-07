defmodule <%= @project.module_name %>.Esbuild do
  def child_spec(args) do
    %{
      id: make_ref(),
      start: {__MODULE__, :start_link, [args]},
      restart: :transient
    }
  end

  def start_link(_args) do
    Task.start_link(Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)])
  end
end
