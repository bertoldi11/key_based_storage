defmodule KeyBasedStorage.Transactions.Transactions do
  alias KeyBasedStorage.Repo
  alias KeyBasedStorage.Schemas.Transaction

  import KeyBasedStorage.Transactions.Querys

  def start_transaction(user) do
    case has_active_transaction?(user) do
      false -> create_new_transaction(user)
      true -> {:error, "Already have an active transaction"}
    end
  end

  def set(key, value, user) do
    case get_active_transaction(user) do
      nil -> {:error, "There is no active transaction"}
      transaction -> update_transaction(transaction, key, value)
    end
  end

  def get(key, user) do
    case get_active_transaction(user) do
      nil -> nil
      transaction -> get_value_from_transaction(transaction, key)
    end
  end


  def rollback_transaction(user) do
    case get_active_transaction(user) do
      nil -> {:error, "There is no active transaction"}
      transaction -> do_rollback_transaction(transaction)
    end
  end

  def commit_transaction(user) do
    case get_active_transaction(user) do
      nil -> {:error, "There is no active transaction"}
      transaction -> do_commit_transaction(transaction)
    end
  end

  def has_active_transaction?(user) do
    case get_active_transaction(user) do
      nil -> false 
      _ -> true
    end
  end

  def get_changes_to_commit(user) do
    case get_active_transaction(user) do
      nil -> {:error, "There is no active transaction"}
      transaction -> transaction.changes
    end
  end


  defp get_value_from_transaction(%Transaction{changes: nil}, _key) do
    nil
  end

  defp get_value_from_transaction(%Transaction{changes: changes}, key) do
    value = get_change_value_from_key(changes, key)
    {:ok, %{value: value}}
  end

  defp update_transaction(%Transaction{changes: nil} = transaction, key, value) do
    new_changes = add_transaction_change([], key, value)

    case do_update_transaction(transaction, new_changes) do
      {:ok, _transaction} -> {:ok, %{value: value, previous_value: nil}}
      {:error, _} -> {:error, "Error updating transaction"}
    end
  end

  defp update_transaction(%Transaction{changes: changes} = transaction, key, value) do
    new_changes =
      case changes_has_key?(changes, key) do
        true -> update_transaction_change(changes, key, value)
        false -> add_transaction_change(changes, key, value)
      end
    
    previous_value = get_change_value_from_key(changes, key)

    case do_update_transaction(transaction, new_changes) do
      {:ok, _transaction} -> {:ok, %{value: value, previous_value: previous_value}}
      {:error, _} -> {:error, "Error updating transaction"}
    end

  end

  defp do_rollback_transaction(transaction) do
    transaction 
    |> Transaction.changeset(%{status: :rolled_back})
    |> Repo.update()
  end

  defp do_commit_transaction(transaction) do
    transaction 
    |> Transaction.changeset(%{status: :commited})
    |> Repo.update()
  end

  defp do_update_transaction(transaction, changes) do
    transaction
    |> Transaction.changeset(%{changes: changes})
    |> Repo.update()
  end

  defp add_transaction_change(changes, key, value) do
    changes ++ [%{key: key, value: value}]
  end

  defp update_transaction_change(changes, key, value) do
    Enum.map(changes, fn %{"key" => k, "value" => v}  -> 
      case k == key do
        true -> %{key: k, value: value}
        false -> %{key: k, value: v}
      end
    end)
  end

  defp get_change_value_from_key(changes, key) do
    changes
    |> Enum.find(fn %{"key" => k, "value" => _v}  ->  k == key end)
    |> case do
      nil -> nil
      change -> change["value"]
    end
  end

  defp changes_has_key?(changes, key) do
    Enum.any?(changes, fn %{"key" => k, "value" => _v} -> k == key end)
  end

  defp get_active_transaction(user) do
    user
    |> filter_by_user_name()
    |> filter_by_status(:started)
    |> Repo.one()
  end

  defp create_new_transaction(user) do
    %Transaction{}
    |> Transaction.changeset(%{user: user, status: :started})
    |> Repo.insert()
  end
end
