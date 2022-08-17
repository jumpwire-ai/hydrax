defmodule Hydrax.Agent do
  @doc """
  A state wrapper around Hydrax.DeltaCrdt that conforms to the semantics of an Agent.Server.

  This allows for fast local state reads with the tradeoff of eventually consistent writes.
  """

  defmacro __using__(opts) do
    quote do
      @agent __MODULE__

      use Hydrax.DeltaCrdt,
        cluster_mod: {Hydrax.Agent, unquote(opts)},
        cluster_name: @agent

      def get(), do: Agent.get(@agent, & &1)
      def get(fun) when is_function(fun, 1), do: Agent.get(@agent, fun)
      def get(key, default \\ %{}), do: get(fn data -> Map.get(data, key, default) end)
      def get(mod, fun, args), do: Agent.get(@agent, mod, fun, args)
      def update(fun), do: Agent.update(@agent, fun)
      def update(mod, fun, args), do: Agent.update(@agent, mod, fun, args)
      def get_and_update(fun), do: Agent.get_and_update(@agent, fun)
      def get_and_update(mod, fun, args), do: Agent.get_and_update(@agent, mod, fun, args)
      def put(key, value), do: update(fn data -> Map.put(data, key, value) end)
    end
  end


  use GenServer

  def start_link(args) do
    args = Enum.into(args, %{})
    GenServer.start_link(__MODULE__, args, name: args[:name])
  end

  def init(args = %{crdt: crdt}) do
    {data, args} = Map.pop(args, :data, %{})
    {:ok, data} = Agent.Server.init(fn -> data end)
    DeltaCrdt.put(crdt, :agent_data, data)
    Hydrax.DeltaCrdt.init(args)
  end

  def handle_call({:set_members, members}, from, state) do
    Hydrax.DeltaCrdt.handle_call({:set_members, members}, from, state)
  end

  def handle_call(:members, from, state) do
    Hydrax.DeltaCrdt.handle_call(:members, from, state)
  end

  def handle_call(op, from, state = %{crdt: crdt}) do
    process_update(crdt, fn data ->
      {res, reply, data} = Agent.Server.handle_call(op, from, data)
      {data, {res, reply, state}}
    end)
  end

  def handle_cast(op, state = %{crdt: crdt}) do
    process_update(crdt, fn data ->
      {:noreply, data} = Agent.Server.handle_cast(op, data)
      {data, {:noreply, state}}
    end)
  end

  def code_change(old, state = %{crdt: crdt}, fun) do
    process_update(crdt, fn data ->
      {:ok, data} = Agent.Server.code_change(old, data, fun)
      {data, {:ok, state}}
    end)
  end

  defp process_update(crdt, fun) when is_function(fun, 1) do
    # For simplicity, populate only a single key in the DeltaCrdt process.
    # If the map grows too large it may be necessary to diff this locally.
    {data, result} = DeltaCrdt.read(crdt, [:agent_data]) |> Map.get(:agent_data) |> fun.()
    DeltaCrdt.put(crdt, :agent_data, data)
    result
  end
end
