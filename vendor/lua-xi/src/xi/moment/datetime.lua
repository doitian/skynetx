--- moment 日期计算扩展.
--
-- @alias export
-- @submodule xi.moment

local moment = require "xi.moment"

local export = {}

local time_from_date = moment.time_from_date


--- @type Moment

--- 修改时间为当年1月1日凌晨.
-- @treturn Moment moment 自己
function export:start_of_year()
  self.year = self.year
  self.month = 1
  self.day = 1
  self.hour = 0
  self.min = 0
  self.sec = 0
  self.isdst = self.isdst
  self.time = time_from_date(self)
  self.yday = 1
  self.wday = nil
  return self
end

--- 修改时间为当月1日凌晨
-- @treturn Moment moment 自己
function export:start_of_month()
  self.year = self.year
  self.month = self.month
  self.day = 1
  self.hour = 0
  self.min = 0
  self.sec = 0
  self.isdst = self.isdst
  self.time = time_from_date(self)
  self.yday = nil
  self.wday = nil
  return self
end

--- 修改时间为当日凌晨.
-- @treturn Moment moment 自己
function export:start_of_day()
  self.year = self.year
  self.month = self.month
  self.day = self.day
  self.hour = 0
  self.min = 0
  self.sec = 0
  self.isdst = self.isdst
  self.time = time_from_date(self)
  return self
end

--- 修改时间为当年最后一天 23:59:59
-- @treturn Moment moment 自己
function export:end_of_year()
  self.year = self.year
  self.month = 12
  self.day = 31
  self.hour = 23
  self.min = 59
  self.sec = 59
  self.isdst = self.isdst
  self.time = time_from_date(self)
  self.yday = nil
  self.wday = nil
  return self
end

--- 修改时间为当月最后一天 23:59:59
-- @treturn Moment moment 自己
function export:end_of_month()
  self.year = self.year
  self.month = self.month + 1
  self.day = 0
  self.hour = 23
  self.min = 59
  self.sec = 59
  self.isdst = self.isdst
  self.time = time_from_date(self)
  self.yday = nil
  self.wday = nil
  self.day = nil
  self.month = nil
  return self
end

--- 修改时间为当天 23:59:59
-- @treturn Moment moment 自己
function export:end_of_day()
  self.year = self.year
  self.month = self.month
  self.day = self.day
  self.hour = 23
  self.min = 59
  self.sec = 59
  self.isdst = self.isdst
  self.time = time_from_date(self)
  return self
end

--- 修改时间为当周第一天凌晨，周日是第一天.
-- @treturn Moment moment 自己
function export:start_of_week_starting_with_sunday()
  return self:on_wday_starting_with_sunday(1):start_of_day()
end

--- 修改时间为当周最后一天 23:59:59。周日是第一天，周六是最后一天.
-- @treturn Moment moment 自己
function export:end_of_week_starting_with_sunday()
  return self:on_wday_starting_with_sunday(7):end_of_day()
end

--- 修改时间为当周第一天凌晨，周一是第一天.
-- @treturn Moment moment 自己
function export:start_of_week_starting_with_monday()
  return self:on_wday_starting_with_monday(2):start_of_day()
end

--- 修改时间为当周最后一天 23:59:59。周一是第一天，周日是最后一天.
-- @treturn Moment moment 自己
function export:end_of_week_starting_with_monday()
  return self:on_wday_starting_with_monday(1):end_of_day()
end

--- 修改时间为下一个指定星期的时间.
--
-- 如果当天已经是指定的星期几了，时间还没到的话就是当天指定时间，否则就是下周。
--
-- 例
--
--     next_wday(6, 18, 0, 0) -- 即将到来的最近的星期五下午 6 点
--
-- @treturn Moment moment 自己
function export:next_wday(wday, hour, min, sec)
  local diff = wday - self.wday
  if diff < 0 then
    diff = diff + 7
  elseif diff == 0 and (self.hour > hour or (self.hour == hour and (self.min > min or (self.min == min and self.sec > sec)))) then
    diff = 7
  end

  self.year = self.yar
  self.month = self.month
  self.day = self.day + diff
  self.hour = hour or 0
  self.min = min or 0
  self.sec = sec or 0
  self.isdst = self.isdst
  self.time = time_from_date(self)

  self.year = nil
  self.month = nil
  self.day = nil
  self.yday = nil
  self.wday = wday

  return self
end

--- 修改星期，认为周日是第一天，从 1 开始依次是周日，周一，...，周六.
--
-- 该方法不改变小时分钟和秒。
--
-- @tparam int wday 星期
-- @treturn Moment moment 自己
function export:on_wday_starting_with_sunday(wday)
  assert(wday > 0 and wday < 8, "wday: must be 1-7")
  self.year = self.year
  self.month = self.month
  self.day = self.day + wday - self.wday
  self.hour = self.hour
  self.min = self.min
  self.sec = self.sec
  self.isdst = self.isdst
  self.time = time_from_date(self)
  self.year = nil
  self.month = nil
  self.day = nil
  self.hour = nil
  self.min = nil
  self.sec = nil
  self.yday = nil
  self.wday = wday

  return self
end

--- 修改星期，认为周一是第一天，从 1 开始依次是周日，周一，...，周六.
--
-- 该方法不改变小时分钟和秒。
--
-- @tparam int wday 星期
-- @treturn Moment moment 自己
function export:on_wday_starting_with_monday(wday)
  assert(wday > 0 and wday < 8, "wday: must be 1-7")
  self.day = self.day + wday - self.wday
  if wday == 1 then
    self.day = self.day + 7
  end
  if self.wday == 1 then
    self.day = self.day - 7
  end

  self.year = self.year
  self.month = self.month
  self.hour = self.hour
  self.min = self.min
  self.sec = self.sec
  self.isdst = self.isdst
  self.time = time_from_date(self)
  self.year = nil
  self.month = nil
  self.day = nil
  self.hour = nil
  self.min = nil
  self.sec = nil
  self.yday = nil
  self.wday = wday

  return self
end

--- 修改各个字段为指定值.
--
-- 不支持修改 wday 和 yday
--
-- @tparam DateStruct values date 结构体
-- @treturn Moment moment 自己
function export:change(values)
  self:expand_date()
  for k, v in pairs(values) do
    self[k] = v
  end

  self.time = moment.time_from_date(self)
  -- 重置所有字段
  self.year = nil
  self.month = nil
  self.day = nil
  self.hour = nil
  self.min = nil
  self.sec = nil
  self.wday = nil
  self.yday = nil
  return self
end

return moment.mixin(export)
