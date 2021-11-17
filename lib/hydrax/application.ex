defmodule Hydrax.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    sup_opts = Application.get_env(:hydrax, :supervisor, [])
    task_opts = Application.get_env(:hydrax, :task_supervisor, [])
    reg_opts = Application.get_env(:hydrax, :registry, [])

    children = [
      {Hydrax.Registry, reg_opts},
      {Hydrax.Supervisor, sup_opts},
      {Hydrax.TaskSupervisor, task_opts},
    ]

    opts = [strategy: :one_for_one, name: Hydrax.Application]
    Supervisor.start_link(children, opts)
  end
end
