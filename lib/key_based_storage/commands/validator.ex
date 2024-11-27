defmodule KeyBasedStorage.Commands.Validator do
  @moduledoc """
    Module responsable to validate and mount commands
  """

  @valid_actions ["GET", "SET", "BEGIN", "COMMIT", "ROLLBACK"]

  @spec validate_command(String.t()) :: {:ok, map()} | {:error, String.t()}
  def validate_command(command) when is_binary(command) do
    parts = String.split(command, " ")

    action =
      parts
      |> get_data_by_position(0)
      |> String.upcase()

    with {true, :action} <- is_action_valid?(action),
         {:ok, params} <- validate_other_params(action, parts) do
      {:ok, %{action: action, params: params}}
    else
      {false, :action} ->
        {:error, "Invalid action: #{action}}"}

      {false, :key} ->
        {:error, "Invalid key: #{get_data_by_position(parts, 1)}"}

      {false, :value} ->
        {:error, "Invalid value: #{get_data_by_position(parts, 2)}"}

      {:error, message} ->
        {:error, message}
    end
  end

  def validate_command(_), do: {:error, "Invalid command, must be a string"}

  defp validate_other_params("BEGIN", other_params) when length(other_params) == 1 do
    {:ok, %{}}
  end

  defp validate_other_params("BEGIN", _),
    do: {:error, "Invalid number of parameters for BEGIN command"}

  defp validate_other_params("ROLLBACK", other_params) when length(other_params) == 1 do
    {:ok, %{}}
  end

  defp validate_other_params("ROLLBACK", _),
    do: {:error, "Invalid number of parameters for ROLLBACK command"}

  defp validate_other_params("COMMIT", other_params) when length(other_params) == 1 do
    {:ok, %{}}
  end

  defp validate_other_params("COMMIT", _),
    do: {:error, "Invalid number of parameters for BEGIN command"}

  defp validate_other_params("SET", other_params) when length(other_params) == 3 do
    key = get_data_by_position(other_params, 1)
    value = get_data_by_position(other_params, 2)

    with {true, :key} <- is_key_valid?(key),
         {true, :value} <- is_value_valid?(value) do
      {:ok, %{key: key, value: value}}
    end
  end

  defp validate_other_params("SET", _),
    do: {:error, "Invalid number of parameters for SET command"}

  defp validate_other_params("GET", other_params) when length(other_params) == 2 do
    key = get_data_by_position(other_params, 1)

    with {true, :key} <- is_key_valid?(key) do
      {:ok, %{key: key}}
    end
  end

  defp validate_other_params("GET", _),
    do: {:error, "Invalid number of parameters for GET command"}

  defp is_action_valid?(action) do
    {Enum.member?(@valid_actions, String.upcase(action)), :action}
  end

  defp is_key_valid?(key) when is_binary(key) do
    valid = 
      cond do
        is_key_integer?(key) == true -> false
        is_key_boolean?(key) == true -> false
        true -> true
      end
    {valid, :key}
  end

  defp is_key_valid?(_), do: {false, :key}

  defp is_key_integer?(key) do
    case Integer.parse(key) do
      {_, _} -> true
      :error -> false
    end
  end

  defp is_key_boolean?(key) do
    is_boolean(key) 
  end

  defp is_value_valid?(value) when not is_nil(value) do
    {true, :value}
  end

  defp is_value_valid?(_), do: {false, :value}

  defp get_data_by_position(args, position) do
    args
    |> Enum.at(position)
    |> String.trim()
  end
end
