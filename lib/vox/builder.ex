defmodule Vox.Builder do
  def start do
    {:ok, _pid} = Vox.Builder.Collection.start_link()
  end

  def build do
    Vox.Builder.Collection.empty()
    Vox.Builder.FileFinder.collect(Application.get_env(:vox, :src_dir))
    Vox.Builder.FileCompiler.compile()

    Vox.Builder.FileWriter.write()
  end
end
