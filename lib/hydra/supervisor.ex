defmodule Hydra.Supervisor do
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
end
