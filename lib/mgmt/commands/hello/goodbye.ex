defmodule Mgmt.Commands.Hello.Goodbye do
  use Mgmt.Commander

  usage("goodbye [name]")

  description("Say goodbye to whomever")

  long_description("""
  Say goodbye to the world, or whomever you specify as the first argument
  """)

  execute args do
    salutation =
      case args do
        [] -> "Goodbye, world!"
        [name | _tail] -> "Goodbye, " <> name
      end

    IO.puts(salutation)
  end
end
