defmodule Mgmt.CLI do
  @moduledoc false

  def main(args) do
    :ok = Mgmt.run(args)
  end
end
