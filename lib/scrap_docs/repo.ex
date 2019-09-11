defmodule ScrapDocs.Repo do
  use Ecto.Repo,
    otp_app: :scrap_docs,
    adapter: Ecto.Adapters.Postgres
end
