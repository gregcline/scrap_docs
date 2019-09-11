defmodule ScrapDocs.Doc do
  @moduledoc """
  Represents the state of a single markdown document.
  """
  use GenServer
  import Logger
  alias __MODULE__
  alias ScrapDocs.DocId
  alias ScrapDocs.DocRegistry
  alias ScrapDocs.Client
  alias ScrapDocs.DocTable

  defstruct current_markdown: "",
            current_html: "",
            cursor: %{"value" => %{"ch" => 0, "line" => 0}},
            doc_id: "",
            clients: %{},
            client_set: MapSet.new()

  #########
  ## API ##
  #########
  def start_link({doc_id, client_pid}) do
    Logger.info("Start link: #{inspect(doc_id)}")

    GenServer.start_link(__MODULE__, %Doc{doc_id: doc_id}, name: DocRegistry.via(doc_id))

    GenServer.call(DocRegistry.via(doc_id), {:new_subscriber, client_pid})
  end

  @doc """
  Render the text for a document and broadcast it as HTML
  """
  def render_document(doc_id, markdown, cursor) do
    Logger.info("Called render_document with #{doc_id}")

    GenServer.cast(DocRegistry.via(doc_id), {:render_doc, markdown, cursor})
  end

  @doc """
  Subscribe to a given document.

  Will both subscribe the caller to the pubsub channel for that document_id and
  if necessary start a new genserver to represent the document.
  """
  def subscribe(doc_id) do
    Phoenix.PubSub.subscribe(ScrapDocs.PubSub, doc_id)
    DynamicSupervisor.start_child(ScrapDocs.DocSupervisor, {__MODULE__, {doc_id, self()}})
  end

  ###############
  ## Callbacks ##
  ###############
  @impl true
  def init(doc) do
    case DocTable.get_by_doc_id(doc.doc_id) do
      nil ->
        {:ok, doc}

      stored_doc ->
        render_document(doc.doc_id, stored_doc.markdown, doc.cursor)
        {:ok, doc}
    end
  end

  @impl true
  def handle_call({:new_subscriber, pid}, _from, doc_state) do
    if !MapSet.member?(doc_state.client_set, pid) do
      Logger.info("Starting monitoring of #{inspect(pid)}")
      ref = Process.monitor(pid)
      new_clients = Map.put(doc_state.clients, ref, %Client{})
      new_client_set = MapSet.put(doc_state.client_set, pid)

      new_doc = %Doc{doc_state | clients: new_clients, client_set: new_client_set}

      {:reply, {:ok, new_doc}, new_doc}
    else
      {:reply, {:ok, doc_state}, doc_state}
    end
  end

  @impl true
  def handle_cast({:render_doc, markdown, cursor}, doc_state) do
    Logger.info("Got render_doc cast")

    case Earmark.as_html(markdown) do
      {:ok, rendered, _} ->
        new_state = %Doc{
          doc_state
          | current_markdown: markdown,
            current_html: rendered,
            cursor: cursor
        }

        broadcast_change(
          doc_state.doc_id,
          {:new_render, new_state}
        )

        {:noreply, new_state}

      {:error, _rendered, errors} ->
        new_state = %Doc{
          doc_state
          | current_markdown: markdown,
            cursor: cursor
        }

        broadcast_change(doc_state.doc_id, {:render_error, doc_state, errors})
        {:noreply, new_state}
    end
  end

  def handle_cast(arg, state) do
    Logger.info("Got random cast #{inspect(arg)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _info, _reaons}, doc_state) do
    {client, new_clients} = Map.pop(doc_state.clients, ref)
    Logger.info("Client #{client.id} disconnected from document #{doc_state.doc_id}")

    if %{} == new_clients do
      {:stop, {:shutdown, :no_clients}, doc_state}
    else
      {:noreply, %Doc{doc_state | clients: new_clients}}
    end
  end

  @impl true
  def terminate({:shutdown, :no_clients}, doc_state) do
    case DocTable.get_by_doc_id(doc_state.doc_id) do
      nil ->
        DocTable.insert_doc(doc_state.doc_id, doc_state.current_markdown)

      doc ->
        DocTable.update_markdown(doc, doc_state.current_markdown)
    end

    Logger.info("Stored markdown for #{doc_state.doc_id}")
  end

  def terminate(_, _), do: nil

  #############
  ## Private ##
  #############
  defp broadcast_change(document, content) do
    Logger.info("Broadcasting to: #{inspect(document)}")
    Logger.info("Broadcasting: #{inspect(content)}")
    Phoenix.PubSub.broadcast(ScrapDocs.PubSub, document, content)
  end
end
