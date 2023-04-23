defmodule OpenTelemetryLogExporter.MixProject do
  use Mix.Project

  @version "0.4.0"
  @github_page "https://github.com/marcdel/opentelemetry_log_exporter"

  def project do
    [
      app: :opentelemetry_log_exporter,
      name: "OpenTelemetryLogExporter",
      description: "Sometimes you just wanna look at your spans 🤷🏻‍♂️",
      homepage_url: @github_page,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:opentelemetry, "~> 1.2", only: :test},
      {:opentelemetry_exporter, "~> 1.4", only: :test},
      {:ex_doc, "~> 0.29.4", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp docs do
    [
      api_reference: false,
      authors: ["Marc Delagrammatikas"],
      canonical: "http://hexdocs.pm/opentelemetry_log_exporter",
      main: "OpenTelemetryLogExporter",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      files: ~w(mix.exs README.md lib),
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_page,
        "marcdel.com" => "https://www.marcdel.com"
      },
      maintainers: ["Marc Delagrammatikas"]
    ]
  end
end
