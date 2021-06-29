defmodule HydraTest do
  use ExUnit.Case
  doctest Hydra

  test "greets the world" do
    assert Hydra.hello() == :world
  end
end
