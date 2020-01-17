defmodule Mgmt.Commander.Help do
  alias Mgmt.Commander.Help.Template
  use Mgmt.Commander

  usage("help [command subcommand ...]")

  description("Displays the help menu")

  long_description("""
  Displays the main help menu or subcommands help menu, if given a subcommand
  """)

  execute args do
    case args do
      [command] when is_atom(command) ->
        struct = %Commander{} = command.struct

        commands = prep_commands(struct.commands)
        flags = prep_flags(struct.flags, struct.shorthands)
        global_flags = prep_flags(struct.global_flags, struct.global_shorthands)

        struct |> Template.main(commands, flags, global_flags) |> String.trim() |> IO.puts()

      _ ->
        {:error, "help not found for this command"}
    end
  end

  defp prep_commands([]), do: ""

  defp prep_commands(commands) do
    command_length =
      commands
      |> Enum.map(&String.length(&1.struct.name))
      |> Enum.sort(&(&1 >= &2))
      |> List.first()

    command_length = command_length + 4

    for command <- commands, into: "" do
      struct = command.struct

      padding =
        for _ <- 1..(command_length - String.length(struct.name)), into: "" do
          " "
        end

      "\n  " <> struct.name <> padding <> struct.description
    end
  end

  defp prep_flags([], _), do: ""

  defp prep_flags(flags, shorthands) do
    shorthands = for {shorthand, flag} <- shorthands, do: {flag, shorthand}

    flag_length =
      flags
      |> Enum.map(fn {{name, type}, _} ->
        shorthand = if shorthands[name], do: ", #{shorthands[name]}", else: ""
        String.length("#{name}#{shorthand} [#{type}]")
      end)
      |> Enum.sort(&(&1 >= &2))
      |> List.first()

    flag_length = flag_length + 4

    for {{name, type}, description} <- flags, into: "" do
      shorthand = if shorthands[name], do: ", #{shorthands[name]}", else: ""
      beginning = "#{name}#{shorthand} [#{type}]"
      beginning_length = String.length(beginning)

      padding =
        for _ <- 1..(flag_length - beginning_length), into: "" do
          " "
        end

      "\n  " <> beginning <> padding <> description
    end
  end
end
