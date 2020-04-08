-- luacheck: no global

if not _G then
  harbor = 0
  thread = "$SX_THREAD"
  start = "$SX_SKYNET_CONFIG_NAME"
  bootstrap = "snlua bootstrap"
  luaservice = "integration/?.lua;$SX_SERVICE_PATH"
  lualoader = "$SX_LUA_LOADER"
  snax = "$SX_SNAX_PATH"
  cpath = "$SX_CSERVICE_PATH"
  lua_path = "integration/?.lua;$LUA_PATH"
  lua_cpath = "$LUA_CPATH"

  sx_env = "test"
  db_url = "$SX_DB_TEST_URL"
  port = "$SX_PORT"
else
  local skynet = require 'skynet.manager'
  local logger = require 'sx.logger':child({ printer = print })
  local moment = require 'sx.moment'

  skynet.start(function()
    os.exit(0)
  end)
end
