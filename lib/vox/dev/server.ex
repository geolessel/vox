defmodule Vox.Dev.Server do
  @src_dir Application.compile_env(:vox, :src_dir)
  @output_dir Application.compile_env(:vox, :output_dir)

  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  match "*glob" do
    file_path = Path.join([@output_dir | glob])
    mime_type = MIME.from_path(file_path)

    case File.read(file_path) do
      {:ok, body} ->
        conn
        |> put_resp_content_type(mime_type)
        |> send_resp(200, body)

      {:error, :enoent} ->
        conn
        |> put_resp_content_type(mime_type)
        |> send_resp(404, "Not found")
    end
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
