defmodule Hydrax.DeltaCrdt.DiskStorage do
  @moduledoc """
  Read/write items stored in a Delta CRDT to the local disk. This is useful for recovering
  from a restart of the VM.
  """

  use GenServer

  defmacro __using__(_) do
    quote do
      @behaviour DeltaCrdt.Storage

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker,
          restart: :permanent,
          shutdown: 500,
        }
      end

      def start_link(opts) do
        opts = Application.get_env(:hydrax, __MODULE__) |> Keyword.merge(opts)
        GenServer.start_link(Hydrax.DeltaCrdt.DiskStorage, opts, name: __MODULE__)
      end

      @impl DeltaCrdt.Storage
      def read(name), do: GenServer.call(__MODULE__, {:read, name})

      @impl DeltaCrdt.Storage
      def write(name, storage_format), do: GenServer.call(__MODULE__, {:write, name, storage_format})

      def flush(), do: GenServer.call(__MODULE__, :sync)
    end
  end

  @impl GenServer
  def init(opts) do
    name = Keyword.fetch!(opts, :filename)

    {:ok, table} = :dets.open_file(name, [type: :set, auto_save: 10_000])
    Process.flag(:trap_exit, true)
    {:ok, %{table: table}}
  end

  @impl GenServer
  def terminate(reason, state) do
    :dets.close(state.table)
    reason
  end

  @impl GenServer
  def handle_call({:read, key}, _from, state) do
    data =
      case :dets.lookup(state.table, key) do
        [{^key, data}] -> data
        _ -> nil
      end

    {:reply, data, state}
  end

  @impl GenServer
  def handle_call({:write, key, data}, _from, state) do
    :ok = :dets.insert(state.table, {key, data})
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call(:sync, _from, state) do
    resp = :dets.sync(state.table)
    {:reply, resp, state}
  end
end
