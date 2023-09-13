defmodule Vox.Builder do
  defstruct clean: false, pid: nil

  @type t :: %__MODULE__{
          clean: boolean(),
          pid: pid()
        }

  alias Vox.Builder

  @spec start(Builder.t()) :: Builder.t()
  def start(%Builder{} = opts) do
    {:ok, pid} = Vox.Builder.Collection.start_link()
    %Builder{opts | pid: pid}
  end

  @spec build(Vox.Builder.t()) :: Vox.Builder.t()
  def build(%Builder{} = opts) do
    Vox.Builder.Collection.empty()
    Vox.Builder.FileFinder.collect(Application.get_env(:vox, :src_dir))
    Vox.Builder.FileCompiler.compile()

    Vox.Builder.FileWriter.write(opts)
    opts
  end

  @spec process_args([binary()]) :: Builder.t()
  def process_args(args) do
    # TODO better error handling/reporting for unknown options
    {opts, _args} = OptionParser.parse!(args, strict: [clean: :boolean])

    struct(Builder, opts)
  end
end
