defmodule Mgmt.Commander.Help.Template do
  @moduledoc false
  require EEx

  EEx.function_from_file(:def, :main, "lib/mgmt/commander/help/main.eex", [
    :commander,
    :commands,
    :flags,
    :global_flags
  ])
end
