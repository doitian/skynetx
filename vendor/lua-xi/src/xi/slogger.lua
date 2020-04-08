--- 结构化的日志库.
--
-- - 支持 context，context 中的字段会自动加到每条日志中。
-- - 支持嵌套，创建的子 logger 会继承父 logger 的 context。
-- - 支持任意的序列化库，默认使用 cjson
-- - 支持任意的日志输入方法，默认使用 print
-- - 支持配置时间函数，默认使用 os.time() 获取当前时间
--
-- @see slogger_example.lua
-- @alias export

local sformat = string.format
local ostime = os.time
local osdate = os.date
local dtraceback = debug.traceback
local dgetinfo = debug.getinfo

local slogger = {}
slogger.__index = slogger

--- 日志等级.
-- 采用的 rsyslog 标准的数字
local LEVELS = {
  debug = 7, -- 7 rsyslog debug
  info = 6, -- 6 rsyslog info
  warn = 5, -- 5 rsyslog notice
  error = 4, -- 4 rsyslog warn
  fatal = 3 -- 3 rsyslog err
}

local DEFAULT_LEVEL = LEVELS.debug
local ROOT = { context = {}, encode = nil }

--- 创建一个日志记录对象.
--
-- - name: 日志名字，必须配置
-- - level: 日志等级，默认是 debug
-- - encode: 序列化方法，默认是 cjson.encode
-- - printer: 日志输出方法，默认是 print
-- - time: 获取当前 Unix 时间戳的方法，默认是 os.time
--
-- 例子
--
--     slogger.create({ name = 'root' })
--     slogger.create({ name = 'skynet', level = 'error', address = skynet.self() })
--
-- @tparam table options logger 配置和 context 字段
-- @tparam table parent 父 logger，用于 @{slogger:child}
-- @treturn slogger logger
local function create(options, parent)
  options = options or {}
  parent = parent or ROOT

  local context = {}
  for k, v in pairs(parent.context) do
    context[k] = v
  end
  for k, v in pairs(options) do
    context[k] = v
  end

  local encode = context.encode or parent.encode
  if not encode then
    local cjson = require "cjson".new()
    cjson.encode_sparse_array(true)
    parent.encode = cjson.encode
  end
  context.encode = nil

  assert(context.name, "slogger requires name")

  local level = context.level or parent.level or DEFAULT_LEVEL
  level = LEVELS[level] or level
  context.level = nil

  local time = context.time or parent.time or ostime
  context.time = nil

  local printer = context.printer or parent.printer or print
  context.printer = nil

  return setmetatable({
    level = level,
    encode = encode,
    time = time,
    printer = printer,
    context = context
  }, slogger)
end

--- 返回一个函数用在 xpcall 中记录错误.
--
--    xpcall(func, slogger.xpcall_handler(logger, 'fatal'))
--
-- @tparam slogger logger 记录用的 logger
-- @tparam[opt=error] string level 记录用的日志等级
-- @treturn function handler
local function xpcall_handler(logger, level)
  level = level or LEVELS.error
  return function(err)
    logger:log(level, {
      msg = err,
      stacktrace = dtraceback(nil, 2)
    })
  end
end

--- 获得调用处的文件名和行号，合并到 context 中.
--
--    logger:info(slogger.fileline({
--      msg = "this is a logger with file and line info"
--    }))
--
-- @tparam table context
-- @treturn table
local function fileline(context)
  context = context or {}

  context.file = dgetinfo(2, 'S').source
  context.line = dgetinfo(2, 'l').currentline

  return context
end

local REQUIRE_VALID_LOGGER_MSG = "slogger requires valid logger, misuse logger:xx as logger.xx?"

--- Logger class
-- @type slogger

--- 打印一条日志.
--
-- 可以直接将日志等级作为方法调用
--
--    logger:log("debug", "Hello, World")
--    logger:debug("Hello, World")
--    logger:info("Hello, %s", "World")
--    logger:error(slogger.fileline({ msg = "err message" }))
--
--
-- @string level 日志等级，可以是 debug, info, warn, error, fatal
-- @tparam string|function|table msg 日志消息.
-- @param arg1 msg 为 string 时用于 string.format 的额外参数
--
-- 如果是 string 会作为日志的 msg 字段，如果还有剩余的参数会调用 string.format 来生成格式话的消息。
-- 如果是 table 会直接作为日志的字段表。
-- 如果是 function 会调用方法并将返回结果作为日志的字段表。
--
-- 如果生成日志代价比较大，使用 function 性能是最优的。
function slogger:log(level, msg, arg1, ...)
  level = tonumber(LEVELS[level] or level)
  local logger_level = assert(self.level, REQUIRE_VALID_LOGGER_MSG)
  if level <= logger_level then
    local body = msg
    if type(msg) == "string" then
      body = { msg = (arg1 and sformat(msg, arg1, ...) or msg)  }
    elseif type(msg) == "function" then
      body = msg()
    end

    local context = assert(self.context, REQUIRE_VALID_LOGGER_MSG)
    for k, v in pairs(context) do
      if not body[k] then
        body[k] = v
      end
    end

    local ts = assert(self.time, REQUIRE_VALID_LOGGER_MSG)()
    body.time = osdate("%Y-%m-%dT%H:%M:%S%z", ts)
    body.level = level

    assert(self.printer, REQUIRE_VALID_LOGGER_MSG)(
      assert(self.encode, REQUIRE_VALID_LOGGER_MSG)(body)
    )
  end
end

--- 创建子 Logger.
-- 子 Logger 会在创建时复制父 logger 的字段。
-- @tparam table context 子 Logger 需要覆盖和新加的字段
-- @treturn slogger logger
function slogger:child(context)
  return create(context, self)
end

for k, v in pairs(LEVELS) do
  slogger[k] = function(logger, ...)
    logger:log(v, ...)
  end
end

--- @export
return {
  create = create,
  xpcall_handler = xpcall_handler,
  fileline = fileline,
  LEVELS = LEVELS
}
