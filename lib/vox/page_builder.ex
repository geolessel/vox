defmodule Vox.PageBuilder do
  @spec build(page :: %Vox.ProcessedFile{}, template :: binary) :: binary
  def build(page, template) do
    assigns =
      page.bindings
      |> Enum.filter(fn
        {{_, EEx.Engine}, _} -> false
        _ -> true
      end)
      |> Enum.into(Keyword.new())
      |> Keyword.merge(inner_content: page.content)

    EEx.eval_file(template, assigns: assigns)
  end
end
