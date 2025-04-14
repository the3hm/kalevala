defmodule Kalevala.MixProject do
  use Mix.Project

  def project do
    [
      app: :kalevala,
      version: "0.1.1",
      elixir: "~> 1.18.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/oestrich/kalevala",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kalevala.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.3", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37.3", only: :dev, runtime: false},
      {:nimble_parsec, "~> 1.4"},
      {:plug_cowboy, "~> 2.7", optional: true},
      {:ranch, ">= 1.7.0 and < 3.0.0", optional: true},
      {:telemetry, "~> 1.3"},
      {:telnet, "~> 0.1"},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    """
    Kalevala is a world building toolkit for text based games.
    """
  end

  defp aliases do
    [
      check: ["compile --warnings-as-errors", "test", "dialyzer"]
    ]
  end

  defp package() do
    [
      maintainers: ["Eric Oestrich"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/oestrich/kalevala"
      }
    ]
  end
end
