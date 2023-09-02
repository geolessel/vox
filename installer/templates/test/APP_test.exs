defmodule <%= @project.module_name %>Test do
  use ExUnit.Case
  doctest <%= @project.module_name %>

  test "greets the world" do
    assert <%= @project.module_name %>.hello() == :world
  end
end
