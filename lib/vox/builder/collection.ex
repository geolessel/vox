defmodule Vox.Builder.Collection do
  use GenServer

  # TODO: once I'm confident in the compilation process, I can eliminate a lot of these intermediate pieces of state
  @initial_state %{
    collections: MapSet.new(),
    compiled: [],
    templates: [],
    evaled: [],
    files: [],
    final: []
  }

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

  def add_collections(collections) do
    GenServer.cast(__MODULE__, {:add_collections, collections})
  end

  def list_files() do
    GenServer.call(__MODULE__, :list_files)
  end

  def list_finals do
    GenServer.call(__MODULE__, :list_finals)
  end

  def assigns do
    GenServer.call(__MODULE__, :assigns)
  end

  def empty do
    GenServer.call(__MODULE__, :empty)
  end

  def inspect() do
    GenServer.call(__MODULE__, :inspect)
  end

  # ┌──────────────────┐
  # │ Server Callbacks │
  # └──────────────────┘

  def init(_) do
    {:ok, @initial_state}
  end

  def handle_call({:add, {path, :unprocessed}}, _, state) do
    state =
      case Path.basename(path) do
        "_" <> _rest ->
          templates = [path | state.templates]
          Map.put(state, :templates, templates)

        _ ->
          files = [%Vox.Builder.File{source_path: path} | state.files]
          Map.put(state, :files, files)
      end

    {:reply, state, state}
  end

  def handle_call(:list_files, _, state) do
    {:reply, state.files, state}
  end

  # TODO I could probably do this more efficiently by going through each file instead
  def handle_call(:assigns, _, state) do
    assigns =
      state.collections
      |> Enum.reduce(%{}, fn collection, acc ->
        files_in_collection =
          state.compiled
          |> Enum.filter(fn %{collections: collections} -> collection in collections end)

        Map.put(acc, collection, files_in_collection)
      end)
      |> Enum.into([])

    {:reply, assigns, state}
  end

  def handle_call(:inspect, _, state) do
    {:reply, state, state}
  end

  def handle_call(:list_finals, _, state) do
    {:reply, state.final, state}
  end

  def handle_call(:empty, _, state) do
    {:reply, state, @initial_state}
  end

  def handle_cast({:add, {file, type}}, state) do
    state = Map.update(state, type, [], &[file | &1])
    {:noreply, state}
  end

  def handle_cast({:add_collections, collections}, state) do
    collections_for_state =
      collections
      |> Enum.reduce(state.collections, fn collection, acc ->
        MapSet.put(acc, collection)
      end)

    {:noreply, %{state | collections: collections_for_state}}
  end
end
