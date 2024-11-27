defmodule KeyBasedStorageWeb.Plugs.Authentication do
  @moduledoc """
  This plug is responsible for authenticating the client.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "x-client-name") do
      [] ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()

      [user] ->
        assign(conn, :user, user)
    end
  end
end
