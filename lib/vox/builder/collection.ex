defmodule Vox.Builder.Collection do
  use GenServer

  # ┌────────────┐
  # │ Client API │
  # └────────────┘

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def add(collectable, :unprocessed) do
    GenServer.call(__MODULE__, {:add, {collectable, :unprocessed}})
  end

  def add(file, type) when type in [:compiled, :evaled, :final] do
    GenServer.cast(__MODULE__, {:add, {file, type}})
  end

  def list_files() do
    GenServer.call(__MODULE__, :list_files)
  end

  def list_collection(type) do
    GenServer.call(__MODULE__, {:list_collection, type})
  end

  def list_finals do
    GenServer.call(__MODULE__, :list_finals)
  end

  def inspect() do
    GenServer.call(__MODULE__, :inspect)
  end

  # ┌──────────────────┐
  # │ Server Callbacks │
  # └──────────────────┘

  def init(_) do
    {:ok, %{compiled: [], templates: [], evaled: [], files: [], final: []}}
  end

  def handle_call({:add, {path, :unprocessed}}, _, state) do
    state =
      case Path.basename(path) do
        "_" <> _rest ->
          templates = [path | state.templates]
          Map.put(state, :templates, templates)

        _ ->
          files = [path | state.files]
          Map.put(state, :files, files)
      end

    {:reply, state, state}
  end

  def handle_call(:list_files, _, state) do
    {:reply, state.files, state}
  end

  def handle_call({:list_collection, type}, _, state) do
    members =
      state.compiled
      |> Enum.filter(fn %{bindings: bindings} ->
        bindings
        |> Enum.into(%{})
        |> Map.get(:collections, [])
        |> List.wrap()
        |> Enum.any?(&(&1 == type))
      end)

    {:reply, members, state}
  end

  def handle_call(:inspect, _, state) do
    {:reply, state, state}
  end

  def handle_call(:list_finals, _, state) do
    {:reply, state.final, state}
  end

  def handle_cast({:add, {file, type}}, state) do
    state = Map.update(state, type, [], &[file | &1])
    {:noreply, state}
  end
end
