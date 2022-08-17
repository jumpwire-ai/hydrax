defmodule Hydrax.AgentTest do
  use ExUnit.Case, async: true
  doctest Hydrax.Agent

  defmodule TestAgent do
    use Hydrax.Agent
  end

  test "agent api" do
    Supervisor.start_link([{TestAgent, data: %{state: 1337}}], strategy: :one_for_one)
    assert %{state: 1337} == Agent.get(TestAgent, & &1)

    Agent.update(TestAgent, fn _ -> %{state: :distribute_me} end)
    assert %{state: :distribute_me} == Agent.get(TestAgent, & &1)
  end
end
