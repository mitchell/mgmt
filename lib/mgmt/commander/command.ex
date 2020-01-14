defmodule Mgmt.Commander.Command do
  defstruct key: "",
            usage: "",
            description: "",
            long_description: "",
            flags: [],
            hidden: false

  defmacro __using__(_opts) do
    quote bind_quoted: [module: __MODULE__] do
      alias Mgmt.Commander.Command
      import Command

      @before_compile module

      @command %Command{}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def struct do
        @command
      end
    end
  end

  defmacro usage(usage) do
    quote bind_quoted: [usage: usage] do
      key = usage |> String.split(" ") |> List.first()
      @command Map.put(@command, :key, key)
      @command Map.put(@command, :usage, usage)
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
      @command Map.put(@command, :description, description)
    end
  end

  defmacro long_description(long_description) do
    quote bind_quoted: [long_description: long_description] do
      @command Map.put(@command, :long_description, long_description)
    end
  end

  defmacro hidden(hidden) do
    quote bind_quoted: [hidden: hidden] do
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
end
