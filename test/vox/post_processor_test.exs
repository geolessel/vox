defmodule Vox.PostProcessorTest do
  use ExUnit.Case
  doctest Vox.PostProcessor
  alias Vox.PostProcessor

  test "process/1 extracts the file contents and bindings" do
    page = PostProcessor.process("test/support/posts/01-hello-world.eex")

    assert page.bindings == [title: "Hello world", date: ~D[2023-04-16]]

    assert page.content ==
             "<h1>Hello, world</h1>\n\nThis is my first post in my new static site generator project.\nI really hope that you like it."
  end
end
