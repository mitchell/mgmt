defmodule Mgmt.Commander.CommanderError do
  defexception [:message]

  @impl true
  def exception(message), do: %__MODULE__{message: message}
end
