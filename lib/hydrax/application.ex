defmodule Hydrax.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hydrax.Registry,
      Hydrax.Supervisor,
      Hydrax.TaskSupervisor,
    ]

    opts = [strategy: :one_for_one, name: Hydrax.Application]
    Supervisor.start_link(children, opts)
  end
end
