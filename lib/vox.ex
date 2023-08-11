defmodule Vox do
  @doc """
  Insert the contents of a partial file into an EEx file.

  It is a requirement to pass the initial slash character `/`
  in the path to your partial. The rest of `partial_path` is the
  path to the partial file on your filesystem starting from your
  site's `src_dir` (as defined in config.exs).

  The partial file will be evaluated by the EEx engine. If you want
  your partial to have any assigns of its own, pass it as the second
  argument. To pass on _all_ assigns, simply call the function
  with `assigns` as the second argument.

  ## Examples

      # The partial file needs no assigns
      Vox.partial("/partials/copyright.html.eex")

      # The partial file needs _all_ the current assigns
      Vox.partial("/partials/header.html.eex", assigns)

  """
  def partial(partial_path, assigns \\ []) do
    if !String.starts_with?(partial_path, "/"),
      do:
        raise("""
        Partials must be referenced from your source root and therefore require an initial slash.

        For example:
          instead of `#{partial_path}`
               write `/#{partial_path}`
        """)

    Vox.Builder.FileCompiler.partial(partial_path, assigns)
  end
end
