defmodule ScrapDocsWeb.PageController do
  use ScrapDocsWeb, :controller
  alias ScrapDocs.DocId

  def index(conn, _params) do
    redirect(conn, to: "/editor/#{DocId.generate()}")
  end
end
