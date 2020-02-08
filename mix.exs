defmodule Mgmt.MixProject do
  use Mix.Project

  def project do
    [
      app: :mgmt,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: escript(),
      deps: deps(),
      preferred_cli_env: preferred_cli_env(),
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

  defp preferred_cli_env do
    [
      credo: :dev,
      dialyzer: :dev
    ]
  end

  defp aliases do
    [
      build: "escript.build",
      clean: [&clean/1, "clean"],
      install: &install/1,
      lint: ["compile", "credo --strict", "dialyzer"]
    ]
  end

  defp clean(_) do
    :ok = Mix.shell().info("Cleaning ./bin and ./_build")
    0 = Mix.shell().cmd("rm -rf ./bin/*")
  end

  defp install(_) do
    :ok = Mix.shell().info("Installing mgmt and mgmt_askpass to /usr/local/bin")
    0 = Mix.shell().cmd("cp ./bin/mgmt /usr/local/bin/")
    0 = Mix.shell().cmd("cp ./scripts/mgmt_askpass /usr/local/bin/")
  end
end
