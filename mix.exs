defmodule Hydrax.MixProject do
  use Mix.Project

  @version "0.4.0"
  @github_url "https://github.com/extragood-io/hydrax"

  def project do
    [
      app: :hydrax,
      version: @version,
      package: package(),
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Hydrax",
      description: description(),
      source_url: @github_url,
      docs: [extras: ["README.md", "LICENSE"], source_ref: @version]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Hydrax.Application, []}
    ]
  end

  defp deps do
    [
      {:horde, "~> 0.8.4"},
      {:ex2ms, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end

  defp description do
    "Shared functionality for working with PIDs across a distributed cluster. Acts as a wrapper
around [Horde](https://hex.pm/packages/horde), providing a few convenience functions such as helpers for working with two-element registry keys."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_url},
    ]
  end
end
