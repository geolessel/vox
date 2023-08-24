defmodule Vox.Builder.File do
  defstruct bindings: [],
            collections: [],
            compiled: nil,
            content: "",
            destination_path: "",
            final: "",
            source_path: "",
            template: "",
            type: nil
end
