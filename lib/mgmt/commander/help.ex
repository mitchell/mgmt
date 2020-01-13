defmodule Mgmt.Commander.Help do
  use Mgmt.Commander.Command

  alias Mgmt.Commander.Help.Template

  usage("help [subcommand]")

  description("Displays the help menu")

  long_description("""
  Displays the main help menu or subcommands help menu, if given a subcommand
  """)

  execute args do
    case args do
      [%Mgmt.Commander{} = commander] ->
        command_length =
          commander.commands
          |> Enum.map(&String.length(&1.struct.key))
          |> Enum.sort(&(&1 >= &2))
          |> List.first()

        command_length = command_length + 4

        commands =
          commander.commands
          |> Enum.map(
            &%{
              key: &1.struct.key,
              padding:
                for _ <- 1..(command_length - String.length(&1.struct.key)), into: "" do
                  " "
                end,
              description: &1.struct.description
            }
          )

        IO.puts(Template.main(commander, commands))

      [%Mgmt.Commander{} = commander, command_key] ->
        command = Enum.find(commander.commands, &(&1.struct.key == command_key))

        IO.puts(Template.command(command.struct))
    end
  end
end
