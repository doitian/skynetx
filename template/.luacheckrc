-- vim: ft=lua:
-- luacheck: globals files

include_files = { "src", "service", "snax" }

files["snax"] = {
  new_globals = { "response", "accept", "init", "exit" }
}

files["spec"] = {
  std = "+busted"
}
