defmodule Vox.ProcessedFile do
  @type t :: %__MODULE__{
          content: binary(),
          bindings: map(),
          path: binary(),
          template: binary()
        }

  defstruct content: "", bindings: %{}, path: "", template: ""
end
