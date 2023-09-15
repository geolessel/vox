defmodule Vox.Builder.File do
  @type t :: %__MODULE__{
          bindings: keyword(),
          collections: list(),
          content: binary(),
          destination_path: binary(),
          final: binary(),
          frontmatter: map(),
          root_template: binary(),
          source_path: binary(),
          template: binary(),
          compiled: Macro.t(),
          type: :evaled | :passthrough
        }
  defstruct bindings: [],
            collections: [],
            compiled: nil,
            content: "",
            destination_path: "",
            final: "",
            frontmatter: %{},
            root_template: "",
            source_path: "",
            template: "",
            type: nil
end
