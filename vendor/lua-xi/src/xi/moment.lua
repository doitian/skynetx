--- 时间模块.
--
-- moment 是可修改的，如果想要不改变原来的数据，需要使用 clone 先复制一份。
--
-- 支持修改 moment 的字段会造成各个字段不同步，请使用 xi.moment.datetime 中方法。
--
-- 额外的方法需要 require:
--
-- - xi.moment.datetime 日期相关操作
--
-- @alias export

local ostime = os.time
local osdate = os.date
local sgsub = string.gsub
local smatch = string.match
local sformat = string.format
local mfloor = math.floor
local EPOCH = { year = 1970, month = 1, day = 1, hour = 0, min = 0, sec = 0, isdst = false, yday = 1, wday = 5 }

local system_tz = - ostime(EPOCH)
local time = ostime

-- this module
local export = {
  time = time,
  system_tz = system_tz -- 系统时区偏移秒数
}

-- metatable for moment object
local moment = {}

local option_setter = {
  time = function(v)
    local old = time
    time = v
    export.time = time
    return old
  end
}

--- 选项配置.
--
-- 可配置项：
--
-- - time: 配置时间函数，返回 Linux 时间戳
--
-- @tfield string k 配置名
-- @field v 配置项值
-- @return o 该项配置原来的值
function export.configure(k, v)
  return option_setter[k](v)
end

--- 扩展 moment 的元表，即 Moment 对象的方法.
-- @tparam tab methods 扩展方法
-- @return moment
function export.mixin(methods)
  for k, v in pairs(methods) do
    moment[k] = v
  end

  return export
end

--- 通过 Linux 时间戳创建 moment 对象.
-- @int timestamp[opt=当前时间] Linux 时间戳
-- @int tz[opt=本地时间时区] 时区偏移秒数，0 表示 UTC 时间
-- @treturn Moment moment
function export.at(timestamp, tz)
  return setmetatable({ time = timestamp or time(), tz = tz or system_tz }, moment)
end
local at = export.at


--- 获得当前的本地时间
-- @treturn Moment moment
-- @function now
export.now = export.at

--- 获得 UTC 时间
-- @int[opt=当前时间] timestamp Linux 时间戳
-- @treturn Moment moment
function export.utc(timestamp)
  return at(timestamp or time(), 0)
end

--- 解析符合 ISO 8601 标准的时间字符串
-- @string str 符合 ISO 8601 标准的时间字符串
-- @treturn Moment moment
function export.parse_iso_8601(str)
  local struct = { time = - system_tz, tz = system_tz, utc = false, year = 1970, month = 1, day = 1, hour = 0, min = 0, sec = 0 }
  local replaced

  local remain = sgsub(str, '^(%d%d%d%d)%-?(%d%d)%-?(%d%d)', function(year, month, day)
    struct.year = tonumber(year)
    struct.month = tonumber(month)
    struct.day = tonumber(day)
    return ''
  end)

  remain, replaced = sgsub(remain, '^[T ](%d%d):?(%d%d)', function(hour, min)
    struct.hour = tonumber(hour)
    struct.min = tonumber(min)
    return ''
  end)

  if replaced > 0 then
    remain = sgsub(remain, '^:?(%d%d)', function(sec)
      struct.sec = tonumber(sec)
      return ''
    end)
  end

  if remain == '' then
    -- localtime
    struct.time = ostime(struct)
    return setmetatable(struct, moment)
  elseif remain == 'Z' then
    -- utc
    struct.tz = 0
    struct.time = ostime(struct) + system_tz
    return setmetatable(struct, moment)
  end

  local s, h, m = smatch(remain, "^([+-])(%d%d):?(%d%d)$")
  assert(s, "invalid iso 8601 date string " .. str)
  local tz = tonumber(h) * 3600 + tonumber(m) * 60
  if s == "-" then
    tz = - tz
  end

  struct.tz = tz
  if tz == system_tz then
    struct.time = ostime(struct)
    return setmetatable(struct, moment)
  else
    return at(ostime(struct) + system_tz - tz, tz)
  end
end

--- date 结构体.
-- @field year 年 2016
-- @field month 月 1-12
-- @field day 日 1-31
-- @field hour 小时 0-23
-- @field min 分钟 0-59
-- @field sec 秒 0-61
-- @field isdst 是否在 Daylight Saving Time 起效中
-- @field tz 时区偏移, nil 表示本地时间
-- @table DateStruct

--- 将 date 结构转成 moment.
--
-- 在标准库 os.date("*t") 结果h解析符合 ISO 8601 标准的时间字符串
-- @tparam DateStruct date 结构体，注意月和日是可以超过范围的，比如 day 为 0 会自动转成上个月最后一天。
-- @treturn Moment moment
function export.from_date(date)
  local tz = date.tz or system_tz
  if tz == system_tz then
    return at(ostime(date))
  else
    return at(ostime(date) + system_tz - tz, tz)
  end
end

--- 将 date 结构转成时间戳
-- @tparam DateStruct date 结构体
-- @treturn int timestamp
function export.time_from_date(date)
  local tz = date.tz or system_tz
  if tz == system_tz then
    return ostime(date)
  else
    return ostime(date) + system_tz - tz
  end
end

--- 函数 `parse_iso_8601` 的别名.
-- @function parse
export.parse = export.parse_iso_8601

--- @type Moment

--- 复制
-- @treturn Moment moment 复制出来的时间结构
function moment:clone()
  return at(self.time, self.tz)
end

--- 修改时区，会原地修改当前对象.
-- @treturn Moment moment 返回指定时区偏移地址的时间
function moment:in_tz(tz)
  if self.tz ~= tz then
    for k, _ in pairs(EPOCH) do
      self[k] = nil
    end
    self.tz = tz
  end
  return self
end
local in_tz = moment.in_tz

local function tz_info(tz)
  local m = tz / 60
  if tz > 0 then
    return sformat('+%02d%02d', mfloor(m / 60), mfloor(m) % 60)
  else
    return sformat('-%02d%02d', mfloor(m / 60), mfloor(m) % 60)
  end
end

--- 转换成 UTC 时间，会原地修改当前对象.
-- @treturn Moment utc 返回转换后新的时间对象，原来的对象不变
function moment:to_utc()
  return in_tz(self, 0)
end

--- 转换成本地时间，会原地修改当前对象.
-- @treturn Moment local 返回转换后新的时间对象，原来的对象不变
function moment:to_local()
  return in_tz(self, system_tz)
end

--- 转成 ISO 8601 标准的字符串
-- @treturn string str
function moment:iso_8601()
  if self.tz == 0 then
    return osdate("!%Y-%m-%dT%H:%M:%SZ", self.time)
  elseif self.tz == system_tz then
    return osdate("%Y-%m-%dT%H:%M:%S", self.time)
  else
    return osdate("!%Y-%m-%dT%H:%M:%S", self.time + self.tz) .. tz_info(self.tz)
  end
end

--- 根据给出的格式将时间转成字符串。非本地和 UTC 时间无法处理 %z %Z 等时区信息.
-- @string str 格式字符串，参考 os.date
-- @treturn string output
function moment:format(str)
  if self.tz == system_tz then
    return osdate(str, self.time)
  else
    return osdate("!" .. str, self.time + self.tz)
  end
end

--- 方便调试.
-- @treturn string output 打印结构体所有字段
function moment:inspect()
  local ret = '{"moment"'
  for k, v in pairs(self) do
    if type(v) ~= 'function' then
      ret = ret .. ',' .. k .. '=' .. tostring(v)
    end
  end
  return ret .. ',str="' .. tostring(self) .. '"}'
end

--- 默认日期字段用到才展开，调用此方法可以强制展开.
-- @treturn Moment moment
function moment:expand_date()
  self.year = self.year
  self.month = self.month
  self.day = self.day
  self.hour = self.hour
  self.min = self.min
  self.sec = self.sec
  self.wday = self.wday
  self.yday = self.yday
  self.isdst = self.isdst

  return self
end

--- Lazy 计算时间分解字段
-- @local
function moment.__index(h, k)
  local mtval = moment[k]
  if mtval then
    return mtval
  end

  if EPOCH[k] then
    local struct
    if h.tz == system_tz then
      struct = osdate('*t', h.time)
    else
      struct = osdate('!*t', h.time + h.tz)
    end
    for newk, v in pairs(struct) do
      h[newk] = v
    end
    return struct[k]
  end

  assert("unknown moment field " .. k)
end

function moment.__add(a, b) return at(a.time + b, a.tz) end
function moment.__sub(a, b) return type(b) ~= "number" and (a.time - b.time) or at(a.time - b, a.tz) end
function moment.__lt(a, b) return a.time < b.time end
function moment.__le(a, b) return a.time <= b.time end
function moment.__eq(a, b) return a.time == b.time end
moment.__tostring = moment.iso_8601

return export
