defmodule KeyBasedStorage.Transactions.Querys do
  import Ecto.Query

  alias KeyBasedStorage.Schemas.Transaction

  def base do
    from(t in Transaction)
  end

  def filter_by_user_name(query \\ base(), user_name) do
    where(query, [t], t.user == ^user_name)
  end

  def filter_by_status(query \\ base(), status) do
    where(query, [t], t.status == ^status)
  end
end
