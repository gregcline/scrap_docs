defmodule ScrapDocsWeb.EditorLive do
  use Phoenix.LiveView
  import Logger

  def mount(%{path_params: %{"id" => doc_id}}, socket) do
    {:error, {:ok, doc}} = ScrapDocs.Doc.subscribe(doc_id)

    {:ok,
     assign(
       socket,
       %{
         output: doc.current_html,
         content: doc.current_markdown,
         cursor:
           Jason.encode!(
             if doc.cursor == %{}, do: %{"value" => %{"line" => 0, "ch" => 0}}, else: doc.cursor
           ),
         doc_id: doc_id,
         client_id: 1,
         user_count: MapSet.size(doc.client_set)
       }
     )}
  end

  def render(assigns) do
    Phoenix.View.render(ScrapDocsWeb.EditorView, "editor.html", assigns)
  end

  def handle_event(
        "editor-changes",
        %{"changes" => changes, "current_text" => current_text, "cursor" => cursor},
        socket
      ) do
    Logger.info("Cursor: #{inspect(cursor)}")

    ScrapDocs.Doc.render_document(socket.assigns.doc_id, current_text, %{
      id: socket.assigns.client_id,
      value: cursor
    })

    {:noreply, socket}
  end

  def handle_event(name, data, socket) do
    Logger.info(inspect(name))
    Logger.info(inspect(data))
    {:noreply, socket}
  end

  def handle_info({:new_render, doc}, socket) do
    Logger.info("New render")
    # {:noreply, socket}
    {:noreply,
     assign(socket, %{
       output: doc.current_html,
       content: doc.current_markdown,
       cursor: Jason.encode!(doc.cursor),
       user_count: MapSet.size(doc.client_set)
     })}
  end

  # def handle_info({:render_error, errors, original_output, cursor}, socket) do
  #   {:noreply, assign(socket, %{
  #     output:
  #   })}
  # end
end
