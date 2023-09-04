import Config

src_dir = "<%= @project.src_dir %>"
output_dir = "<%= @project.output_dir %>"

config :vox, src_dir: src_dir, output_dir: output_dir
<%= if @project.esbuild do %>
config :esbuild,
  version: "0.19.2",
  default: [
    args: ~w(../assets/app.js --bundle --target=es2016 --outdir=../#{output_dir}/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]<% end %>
