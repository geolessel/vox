defmodule <%= @project.module_name %>.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
        <%= @project.module_name %>.Esbuild
    ]

    opts = [strategy: :one_for_one, name: <%= @project.module_name %>.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
