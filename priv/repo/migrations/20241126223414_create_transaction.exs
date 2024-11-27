defmodule KeyBasedStorage.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transaction) do
      add :user, :string
      add :status, :string
      add :changes, {:array, :map}

      timestamps(type: :utc_datetime)
    end
  end
end
