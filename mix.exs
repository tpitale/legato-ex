defmodule Legato.Mixfile do
  use Mix.Project

  def project do
    [app: :legato,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/tpitale/legato-ex",
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp description do
    "Google Analytics Reporting API v4 in Elixir"
  end

  defp package do
    [
      maintainers: ["Tony Pitale"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/tpitale/legato-ex"}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"}
    ]
  end
end
