defmodule Maily.MixProject do
  use Mix.Project

  def project do
    [
      app: :maily,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Maily.Application, []}
    ]
  end

  defp deps do
    [
      {:broadway_rabbitmq, "~> 0.8"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.3"},
      {:ex_cldr, "~> 2.44"},
      {:ex_cldr_dates_times, "~> 2.25"},
    ]
  end
end
