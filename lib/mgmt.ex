defmodule Mgmt do
  @moduledoc """
  Documentation for Mgmt.
  """
  def run([]), do: IO.puts("Hello, world!")

  def run([arg | _tail]), do: IO.puts("Hello, " <> arg)
end
