defmodule Vox.Builder.File do
  @src_dir Application.compile_env(:vox, :src_dir)

  defstruct bindings: [],
            collections: [],
            compiled: nil,
            content: "",
            destination_path: "",
            final: "",
            frontmatter: [],
            root_template: "#{@src_dir}/_root.html.eex",
            source_path: "",
            template: "",
            type: nil
end
