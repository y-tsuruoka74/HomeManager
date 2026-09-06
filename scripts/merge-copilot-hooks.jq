# Replace only the exact command owned by this module. Keep all other hooks.
(if length == 0 then {} elif length == 1 then .[0]
 else error("expected one config object") end)
| if type != "object" then error("config must be an object") else . end
| if .hooks != null and (.hooks | type) != "object"
  then error("hooks must be an object") else . end
| if .hooks.SessionStart != null and (.hooks.SessionStart | type) != "array"
  then error("SessionStart must be an array") else . end
| .hooks.SessionStart = (
    [(.hooks.SessionStart // [])[]
      | select(.bash as $command | all($entries[]; .bash != $command))]
    + $entries
  )
