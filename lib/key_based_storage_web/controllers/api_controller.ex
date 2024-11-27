defmodule KeyBasedStorageWeb.ApiController do
  @moduledoc """
  The API controller for the KeyBasedStorage application.
  """

  use KeyBasedStorageWeb, :controller

  alias KeyBasedStorage.Commands.Command
  alias KeyBasedStorage.Commands.Validator

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, _params) do
    user = conn.assigns[:user]

    {:ok, command, conn} = Plug.Conn.read_body(conn)

    with {:ok, %{action: action, params: params}} <- Validator.validate_command(command),
         {:ok, params} <- Command.execute(action, params, user) do
      conn
      |> put_status(:ok)
      |> text(get_response_message(action, params))
    else
      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> text(message)
    end
  end

  defp get_response_message("SET", params) do
    previous_value =
      case params.previous_value do
        nil -> "NIL"
        value -> value
      end

    "#{previous_value} #{params.value}"
  end

  defp get_response_message("GET", params) do
    params.value
  end

  defp get_response_message(_, _) do
    "OK"
  end
end
