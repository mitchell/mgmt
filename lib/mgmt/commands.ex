defmodule Mgmt.Commands do
  @spec run_any_that_exist(cmds :: [String.t()], opts :: keyword) :: boolean
  def run_any_that_exist(cmds, opts \\ [])

  def run_any_that_exist(cmds, sudo: true) do
    bins =
      "PATH"
      |> System.get_env()
      |> String.split(":")

    Enum.any?(cmds, fn cmd ->
      [sudo, program | args] = String.split(cmd, " ")

      if Enum.any?(bins, &File.exists?("#{&1}/#{program}")) do
        {%IO.Stream{}, _code} =
          System.cmd(sudo, [program | args],
            env: [{"SUDO_ASKPASS", "/usr/local/bin/mgmt_askpass"}],
            into: IO.stream(:stdio, :line)
          )

        true
      else
        false
      end
    end)
  end

  def run_any_that_exist(cmds, _opts) do
    bins =
      "PATH"
      |> System.get_env()
      |> String.split(":")

    Enum.any?(cmds, fn cmd ->
      [program | args] = String.split(cmd, " ")

      if Enum.any?(bins, &File.exists?("#{&1}/#{program}")) do
        {%IO.Stream{}, _code} = System.cmd(program, args, into: IO.stream(:stdio, :line))
        true
      else
        false
      end
    end)
  end
end
