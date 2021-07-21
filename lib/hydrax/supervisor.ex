defmodule Hydrax.Supervisor do
  @moduledoc """
  A distributed supervisor that dynamically adds and monitors PIDs across the cluster.
  """

  use Horde.DynamicSupervisor

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(init_arg) do
    [strategy: :one_for_one, members: :auto, process_redistribution: :active]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  def which_children(), do: Horde.DynamicSupervisor.which_children(__MODULE__)
  def terminate_child(child_pid), do: Horde.DynamicSupervisor.terminate_child(__MODULE__, child_pid)
end
