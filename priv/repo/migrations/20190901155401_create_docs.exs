defmodule ScrapDocs.Repo.Migrations.CreateDocs do
  use Ecto.Migration

  def change do
    create table(:docs) do
      add(:markdown, :string)
      add(:doc_id, :string)

      timestamps()
    end
  end
end
