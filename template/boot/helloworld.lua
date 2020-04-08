-- luacheck: no global
harbor = 0
thread = "$SX_THREAD"
start = "start_helloworld"
bootstrap = "snlua bootstrap"
luaservice = "$SX_SERVICE_PATH"
lualoader = "$SX_LUA_LOADER"
snax = "$SX_SNAX_PATH"
cpath = "$SX_CSERVICE_PATH"
lua_path = "$LUA_PATH"
lua_cpath = "$LUA_CPATH"

logger = "$SX_LOGGER"
logger = logger ~= "" and logger or nil
logservice = "$SX_LOGSERVICE"
loglevel = "$SX_LOGLEVEL"

sx_env = "$SX_ENV"
db_url = "$SX_DB_URL"
port = "$SX_PORT"
