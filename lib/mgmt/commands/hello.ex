defmodule Mgmt.Commands.Hello do
  use Mgmt.Commander.Command

  usage("hello [name]")

  hidden(true)

  description("Say hello to whomever")

  long_description("""
  Say hello to the world, or whomever you specify as the first argument
  """)

  execute args do
    greeting =
      case args do
        [] -> "Hello, world!"
        [name | _tail] -> "Hello, " <> name
      end

    IO.puts(greeting)
  end
end
