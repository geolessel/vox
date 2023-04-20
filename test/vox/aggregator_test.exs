defmodule Vox.AggregatorTest do
  use ExUnit.Case
  doctest Vox.Aggregator

  test "find_posts/1 finds all files ending in .eex in a folder and subfolders" do
    posts = Vox.Aggregator.find_posts("test/support/posts")

    assert posts == [
             "test/support/posts/01-hello-world.eex",
             "test/support/posts/02-you-there?.eex",
             "test/support/posts/work/03-awesome-thing.eex"
           ]
  end
end
