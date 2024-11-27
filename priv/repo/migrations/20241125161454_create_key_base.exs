defmodule KeyBasedStorage.Repo.Migrations.CreateKeyBase do
  use Ecto.Migration

  def change do
    create table(:key_base) do
      add :key, :string
      add :value_string, :string
      add :value_integer, :integer
      add :value_boolean, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
