--- 根 logger.
--
-- 返回 @{xi.slogger} 的对象作为 skynet 中所有日志的 root logger.
--
-- - 使用 cjson 序列化，序列化失败会记录下错误并把安全的字段抽取出来再重新序列化
-- - 使用 skynet.error 输出，可以配合 @{cservice.sx_syslog} 实现输入到 syslog
-- - 使用 skynet.time 获得时间
-- - 使用 skynet env loglevel 获得日志过滤等级
--
-- @module sx.logger
local slogger = require 'xi.slogger'
local LEVELS = slogger.LEVELS

local dtraceback = debug.traceback
local cjson = require 'cjson.safe'.new()
cjson.encode_sparse_array(true)
local encode = cjson.encode
local time = os.time
local printer = print
local level

local logger

local SAFE_TYPES = {
  number = true,
  string = true,
  boolean = true
}

pcall(function()
  local skynet = require 'skynet'
  printer = skynet.error

  local skynet_time = skynet.time
  local mfloor = math.floor

  time = function()
    return mfloor(skynet_time())
  end

  level = LEVELS[skynet.getenv('loglevel')]
end)

local function safe_encode(obj)
  local encoded, err = encode(obj)

  if err ~= nil then
    if logger then
      logger:fatal({
        msg = err,
        stacktrace = dtraceback()
      })
    end

    local safe_obj = {}
    for k, v in pairs(obj) do
      local vtype = type(v)
      if SAFE_TYPES[vtype] then
        safe_obj[k] = v
      else
        safe_obj['ERR__' .. k] = '[' .. vtype .. ']'
      end
    end

    encoded, err = encode(safe_obj)
  end

  return encoded or err
end

logger = slogger.create({
  name = 'logger',
  level = level,
  time = time,
  encode = safe_encode,
  printer = printer
})

--- 封装 logger:child.
--
-- 可以用来支持创建子 logger.
--
--     require "sx.logger".create({ name = "child" })
function logger.create(...)
  return logger:child(...)
end

return logger

