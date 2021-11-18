defmodule Hydrax.Supervisor do
  @moduledoc """
  A distributed supervisor that dynamically adds and monitors PIDs across the cluster.
  """

  use Horde.DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def start_children(children) do
    Logger.info("Starting #{inspect children}")
    children
    |> Stream.map(fn spec -> {spec, start_child(spec)} end)
    |> Stream.filter(fn {_, result} ->
      case result do
        {:ok, _pid} -> false
        {:error, {:already_started, _pid}} -> false
        :ignore -> false
        _ -> true
      end
    end)
    |> Enum.each(fn res -> Logger.warn("Hydrax supervised child failed to start: #{inspect res}") end)
  end

  @impl true
  def init(init_arg) do
    {children, init_arg} = Keyword.pop(init_arg, :children, [])
    {delay, init_arg} = Keyword.pop(init_arg, :child_init_delay, 500)

    init_arg = [strategy: :one_for_one, members: :auto, process_redistribution: :active]
    |> Keyword.merge(init_arg)

    case Horde.DynamicSupervisor.init(init_arg) do
      {:ok, flags} ->
        spawn(fn ->
          :timer.sleep(delay)
          start_children(children)
        end)
        {:ok, flags}
      res -> res
    end
  end

  def which_children(), do: Horde.DynamicSupervisor.which_children(__MODULE__)
  def terminate_child(child_pid), do: Horde.DynamicSupervisor.terminate_child(__MODULE__, child_pid)
end
