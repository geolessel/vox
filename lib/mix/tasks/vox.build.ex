defmodule Mix.Tasks.Vox.Build do
  @shortdoc "Build a site with HTML"

  @moduledoc """
  Builds a Vox site's HTML.

  ## Command line options

      * `--clean` - delete the output directory before building
  """

  use Mix.Task

  alias Vox.Builder

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    args
    |> Builder.process_args()
    |> Builder.start()
    |> Builder.build()
  end
end
