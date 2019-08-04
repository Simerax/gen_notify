defmodule GenNotify.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_notify,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "GenNotify - A small Library for sending and reacting to notifications in the system",
      licenses: ["MIT"],
      source_url: "https://github.com/Simerax/gen_notify",
      links: %{"GitHub" => "https://github.com/Simerax/gen_notify"}
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
      {:mox, "~> 0.5.1", only: :test}
    ]
  end

end
