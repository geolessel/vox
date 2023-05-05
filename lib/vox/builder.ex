defmodule Vox.Builder do
  def build do
    {:ok, _pid} = Vox.Builder.Collection.start_link()
    Vox.Builder.FileFinder.collect(Application.get_env(:vox, :src_dir))
    Vox.Builder.FileCompiler.compile()

    Vox.Builder.FileWriter.write()
  end
end
