defmodule KeyBasedStorage.Repo do
  use Ecto.Repo,
    otp_app: :key_based_storage,
    adapter: Ecto.Adapters.Postgres
end
