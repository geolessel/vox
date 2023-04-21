defmodule Vox.Posts do
  use GenServer

  # ┌────────────┐
  # │ Client API │
  # └────────────┘

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def add_post(post) do
    GenServer.cast(__MODULE__, {:add_post, post})
  end

  # ┌──────────────────┐
  # │ Server Callbacks │
  # └──────────────────┘

  def init(_args) do
    {:ok, []}
  end

  def handle_call(:all, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_post, post}, state) do
    {:noreply, [post | state]}
  end

  # def handle_call(msg, {from, ref}, state) do
  #   # {:reply, reply, state}
  #   # {:reply, reply, state, timeout}
  #   # {:reply, reply, state, :hibernate}
  #   # {:noreply, state}
  #   # {:noreply, state, timeout}
  #   # {:noreply, state, :hibernate}
  #   # {:stop, reason, reply, state}
  #   # {:stop, reason, state}
  # end
  #
  # def handle_cast(msg, state) do
  #   # {:noreply, state}
  #   # {:noreply, state, timeout}
  #   # {:noreply, state, :hibernate}
  # end
  #
  # def handle_info(msg, state) do
  #   # {:noreply, state}
  #   # {:noreply, state, timeout}
  #   # {:stop, reason, state}
  # end
  #
  # def terminate(reason, state) do
  #   :ok
  # end

  # ┌──────────────────┐
  # │ Helper Functions │
  # └──────────────────┘
end
