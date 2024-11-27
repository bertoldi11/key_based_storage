defmodule KeyBasedStorage.Schemas.KeyBase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "key_base" do
    field :key, :string
    field :value_boolean, :boolean
    field :value_integer, :integer
    field :value_string, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(key_base, attrs) do
    cast(key_base, attrs, [:key, :value_string, :value_integer, :value_boolean])
  end
end
