defmodule Vox.Builder.File do
  @src_dir Application.compile_env(:vox, :src_dir)
  @type t :: %__MODULE__{
          bindings: keyword(),
          collections: list(),
          content: binary(),
          destination_path: binary(),
          final: binary(),
          root_template: binary(),
          source_path: binary(),
          template: binary(),
          compiled: any(),
          type: :evaled | :passthrough
        }
  defstruct bindings: [],
            collections: [],
            compiled: nil,
            content: "",
            destination_path: "",
            final: "",
            root_template: "#{@src_dir}/_root.html.eex",
            source_path: "",
            template: "",
            type: nil
end
