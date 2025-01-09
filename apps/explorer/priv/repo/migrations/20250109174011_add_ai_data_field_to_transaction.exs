defmodule Explorer.Repo.Migrations.AddAiDataFieldToTransaction do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:ai_data, :map, default: %{})
    end
  end
end
