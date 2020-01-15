defmodule Mgmt do
  @moduledoc """
  Documentation for Mgmt.
  """
  alias Mgmt.Commands.Hello
  use Mgmt.Commander, [:main, :escript]

  usage("mgmt [command]")

  description("A simple system management tool, for unix-like systems")

  long_description("""
  A simple system management tool, for unix-like systems. Commands include, but are not limited to;
  powering off, suspending, locking, killing processes, and updating packages.
  """)

  commands([Hello])
end
