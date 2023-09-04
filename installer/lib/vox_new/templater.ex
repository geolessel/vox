defmodule VoxNew.Templater do
  defmacro __using__(_env) do
    quote do
      import Mix.Generator
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :templates, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    base_path = Path.expand("../../templates", __DIR__)

    quote do
      @base_templates_path unquote(base_path)
    end

    templates_ast =
      for {template_path, _flag} <- Module.get_attribute(env.module, :templates) do
        path = Path.join(base_path, template_path)
        compiled = EEx.compile_file(path)

        quote generated: true do
          @external_resource unquote(path)
          @file unquote(path)
          def render_template(unquote(template_path), var!(assigns)), do: unquote(compiled)
        end
      end

    quote do
      unquote(templates_ast)
      def template_files(name), do: Keyword.fetch!(@templates, name)
    end
  end

  defmacro template(name, flag \\ true) do
    quote do
      @templates {unquote(name), unquote(flag)}
    end
  end
end
