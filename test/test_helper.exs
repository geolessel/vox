Application.put_env(:vox, :src_dir, "test/support")
Application.put_env(:vox, :output_dir, "_html")

ExUnit.start()
{:ok, _pid} = Vox.Builder.Collection.start_link()
