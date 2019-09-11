defmodule ScrapDocs.DocId do
  use Puid, charset: :safe64, total: 1.0e7, risk: 1.0e3
end
