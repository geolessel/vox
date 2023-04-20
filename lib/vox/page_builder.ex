defmodule Vox.PageBuilder do
  @spec build(page :: %Vox.ProcessedFile{}, template :: binary) :: binary
  def build(page, template) do
    EEx.eval_file(template, assigns: [inner_content: page.content])
  end
end
