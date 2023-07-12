defmodule Vox do
  @doc """
  Insert the contents of a partial file into an EEx file.

  It is a requirement to pass the initial slash character `/`
  in the path to your partial. The rest of `partial_path` is the
  path to the partial file on your filesystem starting from your
  site's `src_dir` (as defined in config.exs).

  Think of this process as a simple copy/paste action.

  This DOES NOT evaulate variables within the partial file (yet).
  """
  def partial(partial_path) do
    if !String.starts_with?(partial_path, "/"),
      do:
        raise("""
        Partials must be referenced from your source root and therefore require an initial slash.

        For example:
          instead of `#{partial_path}`
               write `/#{partial_path}`
        """)

    Vox.Builder.FileCompiler.partial(partial_path)
  end
end
