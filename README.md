# Vox

A Elixir-based static site generator/builder.

## Quick start

There is a new site generator that is the quickest way to get started.
In order to use it, run

```bash
mix archive.install hex vox_new
mix vox.new blog
```

This will generate a simple scaffolded site that you can customize and tweak as you see fit.

### `vox.new` options

- `--esbuild` - include a simple esbuild installation for asset compilation

## Manual installation

The package can be installed by adding `vox` to your list of dependencies in `mix.exs`:

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

To build your site, run `mix vox.build`.

To start a dev server that rebuilds the site on filesystem changes, run `mix vox.dev`.
**Note that for now, you will have to manually reload the page you are on to see the changes.**
Automatic reloading is on the wishlist.

### Root template

**You must have a `src_dir/_root.html.eex` file defined**.
This file contains code that will be in _every_ rendered html file.

Typically, this will contain your initial `html`, `head`, and `body` tags.
Render your further child template with

```elixir
<%= @inner_content %>
```

### Template files

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

### Partials

If you have a bit of code or markup that is reused often in your site, it might be beneficial to put it into a partial.

To render the contents of a partial file, use the **Vox.partial/1** function passing the full path of the file from your source directory.
If your partial needs access to variables your current page has access to, pass them in as the optional second argument.
To pass on _all_ the assigns that your current page has access to, simply pass `assigns` as the second argument.

For example, if you specified your source directory as `my-blog` and you had a partial file located on your filesystem at `my-blog/partials/copyright.html`, you would insert it into an EEx file like...

```elixir
<%= Vox.partial("/partials/copyright.html") %>
```

To let your partial have access to all currently known assigns:

```elixir
<%= Vox.partial("/partials/header.html.eex", assigns %>
```

Note that it is important and required to pass the initial slash `/` in the path.
