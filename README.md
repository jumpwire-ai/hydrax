# Hydrax

Shared functionality for working with PIDs across a distributed cluster. Acts as a wrapper
around [Horde](https://hex.pm/packages/horde), providing a few convenience functions such as helpers for working with two-element registry keys.

![](https://media.giphy.com/media/lRvz4z4Ql1T1UjtKKF/giphy.gif)

## Installation

The package can be installed by adding `hydrax` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hydrax, "~> 0.3"},
  ]
end
```

Then add either the Registry, Supervisor, or both to your application tree:

``` elixir
defmodule Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hydrax.Registry,
      Hydrax.Supervisor,
      # other children
    ]

    opts = [strategy: :one_for_one, name: Application]
    Supervisor.start_link(children, opts)
  end
end
```

The Registry and Supervisor are thin wrappers around Horde.Registry and Horde.DynamicSupervisor. The [Horde documentation](https://hexdocs.pm/horde/readme.html) is the best place to learn how to use these.
