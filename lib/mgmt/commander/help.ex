defmodule Mgmt.Commander.Help do
  alias Mgmt.Commander.Help
  alias Mgmt.Commander.Help.Template
  use Mgmt.Commander

  usage("help [command subcommand ...]")

  description("Displays the help menu")

  long_description("""
  Displays the main help menu or subcommands help menu, if given a subcommand
  """)

  execute args do
    case args do
      [%Mgmt.Commander{} = commander] ->
        commands = prep_commands(commander.commands)
        IO.puts(Template.main(commander, commands))

      [%Mgmt.Commander{} = commander, command_name | tail] ->
        command = Enum.find(commander.commands, &(&1.struct.name == command_name))

        cond do
          command == nil ->
            {:error, "unable to find help for command requested"}

          tail == [] ->
            commands = prep_commands(command.struct.commands)
            IO.puts(Template.main(command.struct, commands))

          true ->
            Help.run([command.struct | tail], [])
        end
    end
  end

  defp prep_commands([]), do: []

  defp prep_commands(commands) do
    command_length =
      commands
      |> Enum.map(&String.length(&1.struct.name))
      |> Enum.sort(&(&1 >= &2))
      |> List.first()

    command_length = command_length + 4

    Enum.map(
      commands,
      &%{
        name: &1.struct.name,
        padding:
          for _ <- 1..(command_length - String.length(&1.struct.name)), into: "" do
            " "
          end,
        description: &1.struct.description
      }
    )
  end
end
