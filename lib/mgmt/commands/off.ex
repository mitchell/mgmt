defmodule Mgmt.Commands.Off do
  import Mgmt.Commands
  use Mgmt.Commander

  usage("off")

  description("Powers off the computer")

  long_description("""
  This command powers off the computer.
  """)

  execute do
    cmds = [
      "sudo systemctl poweroff",
      "sudo launchctl reboot halt"
    ]

    if run_any_that_exist(cmds, sudo: true) do
      :ok
    else
      {:error, "no power off command found", 2}
    end
  end
end
