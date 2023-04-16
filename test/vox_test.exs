defmodule VoxTest do
  use ExUnit.Case
  doctest Vox

  test "greets the world" do
    assert Vox.hello() == :world
  end
end
