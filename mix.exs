defmodule NvidiaDriversFeed.MixProject do
  use Mix.Project

  def project do
    [
      app: :nvidia_drivers_feed,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NvidiaDriversFeed.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.12"},
      {:plug_cowboy, "~> 2.5"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 5.0"},
      {:timex, "~> 3.7"},
      {:xml_builder, "~> 2.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp releases do
    [
      docker: [
        include_executables_for: [:unix],
        steps: [:assemble, :tar],
        path: "/app/release"
      ]
    ]
  end

end
