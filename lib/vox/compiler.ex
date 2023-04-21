defmodule Vox.Compiler do
  def compile do
    Vox.Posts.start_link()
    posts = Vox.Aggregator.find_posts("posts")
    Enum.each(posts, &Vox.Posts.add_post(Vox.PostProcessor.process(&1)))

    index = Vox.PostProcessor.process("pages/index.html.eex")

    Vox.PageBuilder.build(index, "templates/root.html.eex")
  end
end
