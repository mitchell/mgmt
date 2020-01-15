defmodule Mgmt.Commander do
  alias Mgmt.Commander.Help

  defstruct name: "",
            usage: "",
            description: "",
            long_description: "",
            global_flags: [],
            flags: [],
            hidden: false,
            default_command: nil,
            commands: []

  defmacro __using__([]) do
    quote bind_quoted: [module: __MODULE__] do
      alias Mgmt.Commander
      import Commander

      @commander %Commander{}
      @before_compile module
      @main false
      @escript false
    end
  end

  defmacro __using__([_ | _] = opts) do
    quote bind_quoted: [opts: opts, module: __MODULE__] do
      alias Mgmt.Commander
      import Commander

      @main Enum.member?(opts, :main)
      @escript Enum.member?(opts, :escript)

      if @main do
        @commander %Commander{default_command: Help, commands: [Help]}
      else
        @commander %Commander{}
      end

      @before_compile module
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def struct do
        @commander
      end

      if @escript do
        def main(args) do
          :ok = run(__MODULE__, args)
        end
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

  defmacro global_flag(name, type, description, shorthand: shorthand) do
    quote bind_quoted: [name: name, type: type, description: description, shorthand: shorthand] do
      global_flags = @command.global_flags ++ [{name, type, description, shorthand: shorthand}]
      @command Map.put(@command, :global_flags, global_flags)
    end
  end

  defmacro flag(name, type, description, shorthand: shorthand) do
    quote bind_quoted: [name: name, type: type, description: description, shorthand: shorthand] do
      flags = @command.flags ++ [{name, type, description, shorthand: shorthand}]
      @command Map.put(@command, :flags, flags)
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
      if not @main do
        raise ArgumentError, message: "cannot set default_command of non-main commander"
      end

      @commander Map.put(@commander, :default_command, default_command)
    end
  end

  defmacro commands([_ | _] = commands) do
    quote bind_quoted: [commands: commands] do
      commands = Map.get(@commander, :commands) ++ commands
      @commander Map.put(@commander, :commands, commands)
    end
  end

  defmacro hidden(hidden) do
    quote bind_quoted: [hidden: hidden] do
      if @main do
        raise ArgumentError, message: "cannot set main commander to be hidden"
      end

      @command Map.put(@command, :hidden, hidden)
    end
  end

  defmacro execute(do: block) do
    quote bind_quoted: [block: Macro.escape(block, unquote: true)] do
      def run(_args, _flags) do
        unquote(block)
      end
    end
  end

  defmacro execute({args, _, _}, do: block) do
    quote bind_quoted: [args: args, block: Macro.escape(block, unquote: true)] do
      def run(var!(args), _flags) do
        unquote(block)
      end
    end
  end

  defmacro execute({args, _, _}, {flags, _, _}, do: block) do
    quote bind_quoted: [args: args, flags: flags, block: Macro.escape(block, unquote: true)] do
      def run(var!(args), var!(flags)) do
        unquote(block)
      end
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

    {command, args} =
      case Enum.find(commander.commands, &(&1.struct.name == key)) do
        Help ->
          {Help, [commander | args]}

        nil ->
          {commander.default_command, [key | args]}

        command ->
          select_command(command, args)
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

  def select_command(command, []), do: {command, []}

  def select_command(command, [key | tail] = args) do
    if subcommand = Enum.find(command.struct.commands, &(&1.struct.name == key)) do
      select_command(subcommand, tail)
    else
      {command, args}
    end
  end
end
