defmodule Mgmt.Commander.CommanderError do
  @moduledoc """
  This module represents an error that can only get at compile time, when raised by 
  Commander during incorrect usage.
  """
  defexception [:message]

  @impl true
  def exception(message), do: %__MODULE__{message: message}
end
