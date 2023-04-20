defmodule Vox.PageBuilderTest do
  use ExUnit.Case
  doctest Vox.PageBuilder
  alias Vox.PageBuilder

  test "build/2 builds a page within a template" do
    page = Vox.PostProcessor.process("test/support/posts/02-you-there?.eex")

    assert PageBuilder.build(page, "test/support/templates/root.html.eex") == """
           <html>
             <body>
               I'm looking for a sound to drown out the world
             </body>
           </html>
           """
  end
end
