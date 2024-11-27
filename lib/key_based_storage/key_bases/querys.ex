defmodule KeyBasedStorage.KeyBases.Querys do
  import Ecto.Query

  alias KeyBasedStorage.Schemas.KeyBase

  def base do
    from(k in KeyBase)
  end

  def filter_by_key(query \\ base(), key) do
    where(query, [k], k.key == ^key)
  end
end
