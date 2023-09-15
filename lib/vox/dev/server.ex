defmodule Vox.Dev.Server do
  @output_dir Application.compile_env(:vox, :output_dir)

  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler

  plug(PlugLiveReload)
  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  match "*glob" do
    file_path = Path.join([@output_dir | glob])

    handle_request(conn, file_path)
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end

  def handle_request(conn, file_path) do
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

      {:error, :eisdir} ->
        # request was for a directory
        conn
        |> handle_request(Path.join(file_path, "index.html"))
    end
  end
end
