defmodule Vox.Dev.Server do
  use Plug.Builder

  plug Plug.Logger, log: :debug

  def call(conn, opts) do
    conn
    |> super(opts)
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world")
  end
end
