defmodule Mgmt.Commander do
  alias Mgmt.Commander.Help

  defstruct name: "",
            usage: "",
            description: "",
            long_description: "",
            global_flags: [],
            default_command: Help,
            commands: [Help]

  defmacro __using__(_opts) do
    quote bind_quoted: [module: __MODULE__] do
      alias Mgmt.Commander
      import Commander

      @commander %Commander{}

      @before_compile module
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def struct do
        @commander
      end

      def main(args) do
        :ok = run(__MODULE__, args)
      end
    end
  end

  defmacro usage(usage) do
    quote bind_quoted: [usage: usage] do
      name = usage |> String.split(" ") |> List.first()
      @commander Map.put(@commander, :name, name)
      @commander Map.put(@commander, :usage, usage)
    end
  end

  defmacro description(description) do
    quote bind_quoted: [description: description] do
      @commander Map.put(@commander, :description, description)
    end
  end

  defmacro long_description(long_description) do
    quote bind_quoted: [long_description: long_description] do
      @commander Map.put(@commander, :long_description, long_description)
    end
  end

  defmacro default_command(default_command) do
    quote bind_quoted: [default_command: default_command] do
      @commander Map.put(@commander, :default_command, default_command)
    end
  end

  defmacro commands(commands) do
    quote bind_quoted: [commands: commands] do
      commands = Map.get(@commander, :commands) ++ commands
      @commander Map.put(@commander, :commands, commands)
    end
  end

  def run(commander, []) do
    commander = %__MODULE__{} = commander.struct

    if commander.default_command == Help do
      commander.default_command.run([commander], [])
    else
      commander.defualt_command.run([], [])
    end
  end

  def run(commander, [key | args]) do
    commander = %__MODULE__{} = commander.struct

    command =
      if command = Enum.find(commander.commands, &(&1.struct.key == key)) do
        command
      else
        commander.default_command
      end

    args =
      cond do
        command == Help -> [commander | args]
        command == commander.default_command -> [key | args]
        true -> args
      end

    if command do
      case command.run(args, []) do
        :ok ->
          :ok

        {:error, message} ->
          IO.puts("error: " <> message)
          exit({:shutdown, 1})
      end
    else
      IO.puts("error: command not found")
      exit({:shutdown, 1})
    end
  end
end
