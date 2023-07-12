# Vox

1. find all the files to process
   `Vox.Builder.FileFinder`
2. compile non-template files (`EEx.compile_file/1`, `Code.eval_quoted/1`)
   `Vox.Builder.FileCompiler`
3. put compiled files into template files (`EEx.eval_file/2`)
   `Vox.Builder.Templater`
4. save file contents to the correct path

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `vox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vox, "~> 0.1.0"}
  ]
end
```

## Usage

Configure vox in your app (`config/config.exs`):

```elixir
import Config

config :vox, src_dir: "site", output_dir: "_html"
```

Then start writing!
Any file with a `.eex` extension will be compiled and your directory structure beneath your `src_dir` will be retained.
For example, if I have a file named `site/blog/posts/2023/hello-world.html.eex` then that file will be compiled into `_html/blog/posts/2023/hello-world.html`.

### Template file

For now, **you must have a `src_dir/_template.html.eex` file defined**.
The compiler will use that file as the default template.
There are two other ways you can set the template for a file.

1. Bind `template` in the file's bindings. This is a path relative to the file it is bound in.

   ```elixir
   <%
     title = "Special post"
     template = "_special_template.html.eex"
   %>
   ```

2. Change the default of an entire subdirectory by creating a new `_template.html.eex` in it.
When a file is compiled, it will automatically look in its current directory for a `_template.html.eex` file and us that if it exists.
If it does not exist, it will search in the parent directory... and so on until it reaches `src_dir/_template.html.eex`

Use `<%= inner_content %>` inside this file to render the content of other files.

### Passthrough files

There are some files that need to be included in a site's build but should not be processed (like images, fonts, and other assets).
Any file with an extension other than `.eex` or `.html` will not be processed.
Instead, they will be copied over in the same directory structure and file name as it is in the source directory.

For example, if there was an image located on your filesystem at `src_dir/images/logo.png`, it will be available in the generated site structure are `dest_dir/images/logo.png`.

### File metadata (bindings)

In your `.eex` files, any binding you make inside of `<% ... %>` tags will be sent up to the template as an assign.
For example, `<% title = "hello world" %>` in a file can be referenced from `<%= assigns[:title] %>` in a template.

#### Collections

One special metadata (binding) you can use is `collection`.
This will put the file in a special collection you can reference later in your templates or other `.eex` files.

There will be an assign for every collection value you bind in your `.eex` files.
For example, consider the following two files.
First is a blog post specifying it belongs in the `:posts` and `:elixir` collections.

```elixir
<%
  title = "Elixir is cool"
  date = ~D[2023-05-05]
  collections = [:posts, :elixir]
%>

<h1>Elixir is my favorite language</h1>

... lots of must-read content ...
```

Second is an index page listing out all the blog posts and links to their pages.
The `@posts` and `@elixir` are already bound and ready to use because they were indicated in one or more `collections`.

```elixir
<h1>Here are all my blog posts</h1>

<ul>
  <%= for post <- @posts do %>
    <li>
      <a href="<%= post.destination_path %>"><%= post.bindings[:title] %></a>
    </li>
  <% end %>
</ul>
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/vox>.
