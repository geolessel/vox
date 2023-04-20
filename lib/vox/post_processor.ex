defmodule Vox.PostProcessor do
  @spec process(file_path :: binary) :: %Vox.ProcessedFile{}
  def process(file_path) do
    quoted = EEx.compile_file(file_path)
    {content, bindings} = Code.eval_quoted(quoted)
    content = String.trim(content)

    %Vox.ProcessedFile{content: content, bindings: bindings}
  end
end
