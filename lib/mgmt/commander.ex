defmodule Mgmt.Commander do
  alias Mgmt.Commander.{CommanderError, Help}

  defstruct name: "",
            usage: "",
            description: "",
            long_description: "",
            global_flags: [],
            global_shorthands: [],
            flags: [],
            shorthands: [],
            hidden: false,
            default_command: nil,
            commands: []

  @type flag_list :: [{{name :: String.t(), type :: atom}, description :: String.t()}]

  @type t :: %__MODULE__{
          name: String.t(),
          usage: String.t(),
          description: String.t(),
          long_description: String.t(),
          global_flags: flag_list,
          flags: flag_list,
          shorthands: [{shorthand :: atom, name :: atom}],
          hidden: boolean
        }

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts, module: __MODULE__] do
      alias Mgmt.Commander
      import Commander

      @main Enum.member?(opts, :main)
      @escript Enum.member?(opts, :escript)

      if @main do
        @commander %Commander{
          default_command: Help,
          commands: [Help],
          global_flags: [{{:help, :boolean}, "See help for a command"}],
          global_shorthands: [h: :help]
        }
      else
        @commander %Commander{}
      end

      @before_compile module
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @spec struct() :: Commander.t()
      def struct do
        @commander
      end

      if @escript do
        @spec main(args :: [String.t()]) :: :ok
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

  defmacro global_flag(name, type, description, opts \\ []) do
    quote bind_quoted: [name: name, type: type, description: description, opts: opts] do
      global_flags = [{{name, type}, description} | @commander.global_flags]
      @commander Map.put(@commander, :global_flags, global_flags)

      if shorthand = opts[:shorthand] do
        global_shorthands = [{shorthand, name} | @commander.global_shorthands]
        @commander Map.put(@commander, :global_shorthands, global_shorthands)
      end
    end
  end

  defmacro flag(name, type, description, opts \\ []) do
    quote bind_quoted: [name: name, type: type, description: description, opts: opts] do
      flags = [{{name, type}, description} | @commander.flags]
      @commander Map.put(@commander, :flags, flags)

      if shorthand = opts[:shorthand] do
        shorthands = [{shorthand, name} | @commander.shorthands]
        @commander Map.put(@commander, :shorthands, shorthands)
      end
    end
  end

  defmacro description(description) do
    quote bind_quoted: [description: description] do
      if @main do
        raise CommanderError, "description ignored on main commander; use long_description"
      end

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
        raise CommanderError, "cannot set default_command of non-main commander"
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
        raise CommanderError, "cannot set main commander to be hidden"
      end

      @command Map.put(@command, :hidden, hidden)
    end
  end

  defmacro execute(do: block) do
    quote bind_quoted: [block: Macro.escape(block, unquote: true)] do
      @spec run(args :: [String.t()], flags :: keyword) ::
              :ok | {:error, message :: String.t(), code :: pos_integer}
      def run(_args, _flags) do
        unquote(block)
      end
    end
  end

  defmacro execute({args, _, _}, do: block) do
    quote bind_quoted: [args: args, block: Macro.escape(block, unquote: true)] do
      @spec run(args :: [String.t()], flags :: keyword) ::
              :ok | {:error, message :: String.t(), code :: pos_integer}
      def run(var!(args), _flags) do
        unquote(block)
      end
    end
  end

  defmacro execute({args, _, _}, {flags, _, _}, do: block) do
    quote bind_quoted: [args: args, flags: flags, block: Macro.escape(block, unquote: true)] do
      @spec run(args :: [String.t()], flags :: keyword) ::
              :ok | {:error, message :: String.t(), code :: pos_integer}
      def run(var!(args), var!(flags)) do
        unquote(block)
      end
    end
  end

  @spec run(commander :: t, [String.t()]) :: :ok
  def run(commander, []) do
    struct = %__MODULE__{} = commander.struct

    if struct.default_command == Help do
      struct.default_command.run([commander], [])
    else
      struct.defualt_command.run([], [])
    end
  end

  def run(commander, [_ | _] = args) do
    {command, args, flags, shorthands} = select_command(commander, args, [], [])

    {opts, args, _invalid} = OptionParser.parse(args, strict: flags, aliases: shorthands)

    {command, args} =
      cond do
        opts[:help] ->
          {Help, [command]}

        command == Help ->
          {command, _, _, _} = select_command(commander, args, [], [])
          {Help, [command]}

        command == commander ->
          {commander.struct.default_command, args}

        true ->
          {command, args}
      end

    if command do
      case command.run(args, opts) do
        :ok ->
          :ok

        {:error, message, code} ->
          IO.puts("error: " <> message)
          exit({:shutdown, code})
      end
    else
      IO.puts("error: command not found")
      exit({:shutdown, 1})
    end
  end

  defp select_command(command, [], flags, shorthands), do: {command, [], flags, shorthands}

  defp select_command(command, [key | tail] = args, flags, shorthands) do
    struct = %__MODULE__{} = command.struct
    new_global_flags = for {flag, _desc} <- struct.global_flags, do: flag
    new_flags = for {flag, _desc} <- struct.flags, do: flag

    if subcommand = Enum.find(struct.commands, &(&1.struct.name == key)) do
      select_command(
        subcommand,
        tail,
        new_global_flags ++ flags,
        shorthands ++ struct.global_shorthands
      )
    else
      {command, args, new_global_flags ++ new_flags ++ flags,
       shorthands ++ struct.global_shorthands ++ struct.shorthands}
    end
  end
end
