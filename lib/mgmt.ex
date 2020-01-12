defmodule Mgmt do
  @moduledoc """
  Documentation for Mgmt.
  """
  alias Mgmt.Commands.Hello
  use Mgmt.Commander

  name("mgmt")

  description("A simple system management tool, for unix-like systems")

  # default_command(Hello)

  commands([Hello])
end
