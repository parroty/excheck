defmodule ExCheck.Mixfile do
  use Mix.Project

  def project do
    [ app: :excheck,
      version: "0.1.2",
      elixir: "~> 0.14.0",
      deps: deps,
      description: description,
      package: package,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps do
    [
      {:excoveralls, "~> 0.2", only: :test},
      {:triq, github: "krestenkrab/triq"}
    ]
  end

  defp description do
    """
    Property-based testing library for Elixir (QuickCheck style).
    """
  end

  defp package do
    [ contributors: ["parroty"],
      licenses: ["MIT"],
      links: [ { "GitHub", "https://github.com/parroty/excheck" } ] ]
  end
end
