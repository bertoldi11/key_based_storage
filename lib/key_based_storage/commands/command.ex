defmodule KeyBasedStorage.Commands.Command do
  alias KeyBasedStorage.Transactions.Transactions
  alias KeyBasedStorage.KeyBases.KeyBases

  def execute("SET", %{key: key, value: value}, user) do
    case Transactions.has_active_transaction?(user) do
      true -> Transactions.set(key, value, user)
      false -> KeyBases.set(key, value)
    end
  end

  def execute("GET", %{key: key}, user) do
    with true <- Transactions.has_active_transaction?(user),
         {:ok, _params} = response <- Transactions.get(key, user) do
      response
    else
      {:error, message} ->
        {:error, message}

      _ ->
        KeyBases.get(key)
    end
  end

  def execute("COMMIT", _, user) do
    with true <- Transactions.has_active_transaction?(user),
         changes when not is_nil(changes) <- Transactions.get_changes_to_commit(user) do
      Enum.map(changes, fn %{"key" => key, "value" => value} -> 
        KeyBases.set(key, value)
      end)
      Transactions.commit_transaction(user)
    else
      nil -> {:ok, %{}} 
      false -> {:error, "No active transaction"} 
      {:error, message} -> {:error, message}
    end
  end

  def execute("BEGIN", _, user) do
    Transactions.start_transaction(user)
  end

  def execute("ROLLBACK", _, user) do
    Transactions.rollback_transaction(user)
  end
end
