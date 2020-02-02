defmodule Mgmt.MixProject do
  use Mix.Project

  def project do
    [
      app: :mgmt,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: escript(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp escript do
    [main_module: Mgmt, path: "bin/mgmt"]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.2.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      build: ["clean", "lint", &test/1, "escript.build"],
      clean: [&clean_bin/1, "clean"],
      install: &install/1,
      lint: ["compile", &lint/1]
    ]
  end

  def clean_bin(_) do
    :ok = Mix.shell().info("Cleaning ./bin and ./_build")
    0 = Mix.shell().cmd("rm -rf ./bin/*")
  end

  def install(_) do
    :ok = Mix.shell().info("Installing mgmt and mgmt_askpass to /usr/local/bin")
    0 = Mix.shell().cmd("cp ./bin/mgmt /usr/local/bin/")
    0 = Mix.shell().cmd("cp ./scripts/mgmt_askpass /usr/local/bin/")
  end

  def lint(_) do
    0 = Mix.shell().cmd("mix credo --strict", env: [{"MIX_ENV", "dev"}])
    0 = Mix.shell().cmd("mix dialyzer", env: [{"MIX_ENV", "dev"}])
  end

  def test(_) do
    0 = Mix.shell().cmd("mix test")
  end
end
