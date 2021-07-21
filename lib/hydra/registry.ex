defmodule Hydra.Registry do
  @moduledoc """
  A PID registry for use across nodes in a cluster.
  """

  use Horde.Registry
  import Ex2ms

  def start_link(arg), do: Horde.Registry.start_link(__MODULE__, arg, name: __MODULE__)

  def keys(pid), do: Horde.Registry.keys(__MODULE__, pid)
  def lookup(key), do: Horde.Registry.lookup(__MODULE__, key)

  @impl true
  def init(arg) do
    [keys: :unique, members: :auto]
    |> Keyword.merge(arg)
    |> Horde.Registry.init()
  end

  @doc """
  Return the PID via-tuple for an id and name pair.

  ## Examples

  iex> Hydra.Registry.pid_name("foo", "bar")
  {:via, Horde.Registry, {Hydra.Registry, {"foo", "bar"}}}
  """
  def pid_name(id, name) do
    {:via, Horde.Registry, {__MODULE__, {id, name}}}
  end

  @doc """
  Takes a registered name in the form of a :via tuple and unwraps it to return the key.
  """
  def unwrap_pid_name({:via, Horde.Registry, {__MODULE__, name}}), do: name
  def unwrap_pid_name(_), do: nil

  def get_all() do
    selector = fun do {key, pid, _} -> {key, pid} end
    Horde.Registry.select(__MODULE__, selector)
  end

  @doc """
  Remove the given key from the registry.
  """
  def unregister(name = {:via, _, _}), do: name |> unwrap_pid_name() |> unregister()
  def unregister(name), do: Horde.Registry.unregister(__MODULE__, name)

  @doc """
  Lookup all PIDs associated with the given id.
  """
  def select(id) do
    selector = fun do {{pid_id, pid_name}, pid, _} when pid_id == ^id -> {{pid_id, pid_name}, pid} end
    Horde.Registry.select(__MODULE__, selector)
  end

  @doc """
  Lookup the PIDs associated with the given id and name.
  """
  def select(id, name) do
    selector = fun do
      {{pid_id, pid_name}, pid, _} when pid_id == ^id and pid_name == ^name ->
        pid
    end
    Horde.Registry.select(__MODULE__, selector)
  end
end
