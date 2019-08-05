defmodule GenNotify.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_notify,
      version: "0.3.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      name: "GenNotify",
      package: package(),
      source_url: "https://github.com/Simerax/gen_notify",
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
      {:mox, "~> 0.5.1", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description() do
    "GenNotify - A small Library for sending and reacting to notifications in the system"
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Simerax/gen_notify"}
    ]
  end

end
