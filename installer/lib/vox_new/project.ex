defmodule VoxNew.Project do
  @vox_version "0.1.0"

  defstruct app_name: nil,
            base_path: nil,
            esbuild: false,
            module_name: nil,
            output_dir: "_html",
            src_dir: "site",
            vox_version: @vox_version
end
