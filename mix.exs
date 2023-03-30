defmodule TeslaMiddlewareXmlrpc.MixProject do
  use Mix.Project

  @github "https://github.com/cogini/tesla_middleware_xmlrpc"

  def project do
    [
      app: :tesla_middleware_xmlrpc,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: @github,
      homepage_url: @github,
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_add_apps: [:mix]
      ],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger] ++ extra_applications(Mix.env())
    ]
  end

  defp extra_applications(:test), do: [:hackney]
  defp extra_applications(_), do: []

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test], runtime: false},
      {:hackney, "~> 1.18", only: [:dev, :test]},
      {:junit_formatter, "~> 3.3", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:tesla, "~> 1.5"},
      {:xmlrpc, "~> 1.3"}
    ]
  end

  defp description do
    "Middleware for Tesla HTTP client library that encodes and decodes XML-RPC"
  end

  defp package do
    [
      name: "tesla_middleware_xmlrpc",
      maintainers: ["Jake Morrison"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github,
        "Tesla" => "https://github.com/elixir-tesla/tesla",
        "xmlrpc" => "https://github.com/ewildgoose/elixir-xml_rpc"
      }
    ]
  end

  defp docs do
    [
      source_url: @github,
      extras: [
        {"README.md", %{title: "Overview"}},
        {"CHANGELOG.md", %{title: "Changelog"}},
        {"LICENSE", %{title: "License (Apache 2.0)"}},
        {"CODE_OF_CONDUCT.md", %{title: "Code of Conduct"}}
      ],
      # api_reference: false,
      source_url_pattern: "#{@github}/blob/master/%{path}#L%{line}"
    ]
  end
end
