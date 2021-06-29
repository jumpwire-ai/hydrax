defmodule Hydra.MixProject do
  use Mix.Project

  def project do
    [
      app: :hydra,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:horde, "~> 0.8.4"},
      {:ex2ms, "~> 1.0"},
    ]
  end
end
