defmodule KeyBasedStorage.KeyBases.KeyBases do
  alias KeyBasedStorage.Repo
  alias KeyBasedStorage.Schemas.KeyBase

  import KeyBasedStorage.KeyBases.Querys

  def get(key) do
    case key |> filter_by_key() |> Repo.one() do
      nil ->
        {:error, "Key not found #{key}"}

      key_base ->
        value = get_value(key_base)
        {:ok, %{value: value}}
    end
  end

  def set(key, value) do
    value_type = get_value_type(value)
    changes = get_changes_by_type(value_type, value)

    {schema, previous_value} =
      case key |> filter_by_key() |> Repo.one() do
        nil -> {%KeyBase{key: key}, nil}
        key_base -> {key_base, get_value(key_base)}
      end

    case schema |> KeyBase.changeset(changes) |> Repo.insert_or_update() do
      {:ok, _} -> {:ok, %{value: value, previous_value: previous_value}}
      {:error, _} -> {:error, "Error updating key: #{key}"}
    end
  end

  defp get_value_type(value) do
    cond do
      is_value_integer?(value) -> :integer
      is_value_boolean?(value) -> :boolean
      true -> :string
    end
  end

  defp is_value_integer?(key) do
    case Integer.parse(key) do
      {_, _} -> true
      :error -> false
    end
  end

  defp is_value_boolean?(key) do
    case String.contains?(key, "\"") do
      true -> false
      false -> is_string_a_boolean?(key) 
    end
  end
  
  defp is_string_a_boolean?(string) do
    cond do
      string == "false" -> true
      string == "true" -> true
      true -> false
    end
  end

  defp get_changes_by_type(type, value) do
    case type do
      :string -> %{value_string: value, value_integer: nil, value_boolean: nil}
      :integer -> %{value_integer: value, value_string: nil, value_boolean: nil}
      :boolean -> %{value_boolean: value, value_string: nil, value_integer: nil}
      _ -> %{}
    end
  end

  defp get_value(key_value) do
    cond do
      !is_nil(key_value.value_string) -> key_value.value_string
      !is_nil(key_value.value_integer) -> key_value.value_integer
      !is_nil(key_value.value_boolean) -> key_value.value_boolean
      true -> nil
    end
  end
end
