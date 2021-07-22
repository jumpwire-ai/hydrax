defmodule Hydrax.TaskSupervisor do
  @moduledoc """
  A distributed supervisor that dynamically adds and monitors Tasks across the cluster.
  """

  use Horde.DynamicSupervisor

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    Hydrax.Supervisor.init(init_arg)
  end

  # Ideally this could be a drop-in for Task.Supervisor. However, most methods in Task.Supervisor end up calling
  # GenServer.call(supervisor, {:start_task, args, restart, shutdown}, :infinity) where `supervisor` is `Horde.DynamicSupervisorImpl`,
  # and the Horde module does not have a handler for :start_task.

  # def async(fun, options \\ []), do: Task.Supervisor.async(__MODULE__, fun, options)
  # def async(module, fun, args, options \\ []), do: Task.Supervisor.async(__MODULE__, module, fun, args, options)
  # def async_nolink(fun, options \\ []), do: Task.Supervisor.async_nolink(__MODULE__, fun, options)
  # def async_nolink(module, fun, args, options \\ []), do: Task.Supervisor.async_nolink(__MODULE__, module, fun, args, options)
  # def async_stream(enumerable, fun, options \\ []), do: Task.Supervisor.async_stream(__MODULE__, enumerable, fun, options)
  # def async_stream(enumerable, module, function, args, options \\ []), do: Task.Supervisor.async_stream(__MODULE__, enumerable, module, function, args, options)
  # def async_stream_nolink(enumerable, fun, options \\ []), do: Task.Supervisor.async_stream_nolink(__MODULE__, enumerable, fun, options)
  # def async_stream_nolink(enumerable, module, function, args, options \\ []), do: Task.Supervisor.async_stream_nolink(__MODULE__, enumerable, module, function, args, options)

  def start_child(fun) when is_function(fun, 0) do
    spec = %{
      id: Task,
      start: {Task, :start_link, [fun]},
      restart: :temporary
    }
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end
  def start_child(module, fun, args) do
    spec = %{
      id: Task,
      start: {Task, :start_link, [module, fun, args]},
      restart: :temporary
    }
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def children(), do: Horde.DynamicSupervisor.which_children(__MODULE__)
  def terminate_child(child_pid), do: Horde.DynamicSupervisor.terminate_child(__MODULE__, child_pid)
end
