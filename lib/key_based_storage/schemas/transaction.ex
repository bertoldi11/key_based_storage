defmodule KeyBasedStorage.Schemas.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transaction" do
    field :changes, {:array, :map}
    field :status, Ecto.Enum, values: [:started, :commited, :rolled_back]
    field :user, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:user, :status, :changes])
    |> validate_required([:user, :status])
  end
end
