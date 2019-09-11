defmodule ScrapDocs.DocTable do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias __MODULE__
  alias ScrapDocs.Repo

  schema "docs" do
    field(:markdown, :string)
    field(:doc_id, :string)

    timestamps()
  end

  def get_by_doc_id(doc_id) do
    q = from(d in DocTable, where: d.doc_id == ^doc_id)
    Repo.one(q)
  end

  def insert_doc(doc_id, markdown) do
    %DocTable{doc_id: doc_id, markdown: markdown}
    |> change()
    |> Repo.insert()
  end

  def update_markdown(doc, markdown) do
    doc
    |> change(markdown: markdown)
    |> Repo.update()
  end
end
