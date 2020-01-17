defmodule Mgmt.Commander.Help.Template do
  require EEx

  EEx.function_from_file(:def, :main, "lib/mgmt/commander/help/main.eex", [
    :commander,
    :commands,
    :flags,
    :global_flags
  ])
end
