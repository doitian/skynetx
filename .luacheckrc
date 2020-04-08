-- vim: ft=lua:
-- luacheck: globals files

include_files = { "src/sx/*.lua", "src/sx/**/*.lua", "service/sx_*.lua", "snax/sxsn_*.lua" }

files["snax"] = {
  new_globals = { "response", "accept", "init", "exit" }
}

files["spec"] = {
  std = "+busted"
}
