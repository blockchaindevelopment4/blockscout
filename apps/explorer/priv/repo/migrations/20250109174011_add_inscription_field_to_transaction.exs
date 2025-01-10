defmodule Explorer.Repo.Migrations.AddInscriptionFieldToTransaction do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:inscription, :bytea, null: true)
    end
  end
end
