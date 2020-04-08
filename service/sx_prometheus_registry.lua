local INF = math.huge

local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local generic_lua_dispatcher = require "sx.generic_lua_dispatcher"

local tinsert = table.insert
local tconcat = table.concat
local tunpack = table.unpack
local mmin = math.min

-- List of registered collectors.
local collectors_registry = {}
-- List of collector classes.
local collectors_types = {}
-- Metric names already used.
local used_metric_names = {}

local CALL = {}
local SEND = {}

---------------
--- Helpers ---
---------------

local function metric_to_string(value)
  if value == INF then
    return "+Inf"
  elseif value == -INF then
    return "-Inf"
  elseif value ~= value then
    return "Nan"
  else
    return tostring(value)
  end
end

local function escape_string(str)
  return str
    :gsub("\\", "\\\\")
    :gsub("\n", "\\n")
    :gsub('"', '\\"')
end

local function format_sample(metric_name, labels, labels_values, value)
  local labels_specifier = ''
  local len = mmin(#labels, #labels_values)
  if len > 0 then
    local label_parts = {}
    for i = 1, len do
      tinsert(label_parts, labels[i] .. '="' .. escape_string(tostring(labels_values[i])) .. '"')
    end
    labels_specifier = '{' .. tconcat(label_parts, ',') .. '}'
  end

  return metric_name .. labels_specifier .. ' ' .. metric_to_string(value)
end

------------------
--- Collectors ---
------------------

local Counter = {}
Counter.__index = Counter
collectors_types.counter = Counter

function Counter.new(name, help, labels)
  local obj = {
    name = name,
    help = help,
    labels = labels or {},
    samples = {},
    lookup_labels_values = {}
  }
  setmetatable(obj, Counter)
  return obj
end

function Counter:inc(num, labels_values)
  num = num or 1
  labels_values = labels_values or {}
  assert(num >= 0, self.name .. ": Counter increment should not be negative")
  assert(#labels_values == #self.labels, self.name .. ": Counter labels and values unmatch")

  local key = tconcat(labels_values, "\0")
  self.samples[key] = (self.samples[key] or 0) + num
  self.lookup_labels_values[key] = labels_values
end

function Counter:collect()
  if next(self.samples) == nil then
    return {}
  end

  local lines = {}
  tinsert(lines, '# HELP ' .. self.name .. ' ' .. escape_string(self.help))
  tinsert(lines, '# TYPE ' .. self.name .. ' counter')
  for key, value in pairs(self.samples) do
    tinsert(lines, format_sample(self.name, self.labels, self.lookup_labels_values[key], value))
  end

  return lines
end

local Gauge = {}
Gauge.__index = Gauge
collectors_types.gauge = Gauge

function Gauge.new(name, help, labels)
  local obj = {
    name = name,
    help = help,
    labels = labels or {},
    samples = {},
    lookup_labels_values = {}
  }
  setmetatable(obj, Gauge)
  return obj
end

function Gauge:inc(num, labels_values)
  num = num or 1
  labels_values = labels_values or {}
  assert(#labels_values == #self.labels, self.name .. ": Gauge labels and values unmatch")

  local key = tconcat(labels_values, "\0")
  self.samples[key] = (self.samples[key] or 0) + num
  self.lookup_labels_values[key] = labels_values
end

function Gauge:dec(num, labels_values)
  if num then
    self:inc(- num, labels_values)
  end
end

function Gauge:set(num, labels_values)
  labels_values = labels_values or {}
  assert(#labels_values == #self.labels, self.name .. ": Gauge labels and values unmatch")
  assert(type(num) == "number", self.name .. ": Must set to a number")

  local key = tconcat(labels_values, "\0")
  self.samples[key] = num
  self.lookup_labels_values[key] = labels_values
end

function Gauge:collect()
  if next(self.samples) == nil then
    return {}
  end

  local lines = {}
  tinsert(lines, '# HELP ' .. self.name .. ' ' .. escape_string(self.help))
  tinsert(lines, '# TYPE ' .. self.name .. ' gauge')
  for key, value in pairs(self.samples) do
    tinsert(lines, format_sample(self.name, self.labels, self.lookup_labels_values[key], value))
  end

  return lines
end

local Summary = {}
Summary.__index = Summary
collectors_types.summary = Summary

function Summary.new(name, help, labels)
  local obj = {
    name = name,
    help = help,
    labels = labels or {},
    counts = {},
    sums = {},
    lookup_labels_values = {}
  }
  setmetatable(obj, Summary)
  return obj
end

function Summary:observe(value, labels_values)
  labels_values = labels_values or {}
  assert(#labels_values == #self.labels, self.name .. ": Summary labels and values unmatch")

  local key = tconcat(labels_values, "\0")
  self.sums[key] = (self.sums[key] or 0) + value
  self.counts[key] = (self.counts[key] or 0) + 1
  self.lookup_labels_values[key] = labels_values
end

function Summary:collect()
  if next(self.counts) == nil then
    return {}
  end

  local lines = {}
  tinsert(lines, '# HELP ' .. self.name .. ' ' .. escape_string(self.help))
  tinsert(lines, '# TYPE ' .. self.name .. ' summary')
  for key, value in pairs(self.counts) do
    local labels_values = self.lookup_labels_values[key]
    tinsert(lines, format_sample(self.name .. '_count', self.labels, labels_values, value))
    tinsert(lines, format_sample(self.name .. '_sum', self.labels, labels_values, self.sums[key]))
  end

  return lines
end

local Histogram = {}
Histogram.__index = Histogram
collectors_types.histogram = Histogram

function Histogram.new(name, help, labels, buckets)
  local obj = {
    name = name,
    help = help,
    labels = labels or {},
    buckets = buckets,
    counts = {},
    sums = {},
    lookup_labels_values = {}
  }
  tinsert(labels, 'le')
  setmetatable(obj, Histogram)
  return obj
end

function Histogram:observe(value, labels_values)
  labels_values = labels_values or {}
  assert(#labels_values + 1 == #self.labels, self.name .. ": Histogram labels and values unmatch")

  local key = tconcat(labels_values, "\0")
  self.sums[key] = (self.sums[key] or 0) + value
  local buckets_counts = self.counts[key]
  if buckets_counts == nil then
    buckets_counts = {}
    for i, _ in ipairs(self.buckets) do
      buckets_counts[i] = 0
    end
    self.counts[key] = buckets_counts
  end

  buckets_counts[#buckets_counts] = buckets_counts[#buckets_counts] + 1
  for i = #buckets_counts - 1, 1, -1 do
    if value <= self.buckets[i] then
      buckets_counts[i] = buckets_counts[i] + 1
    else
      break
    end
  end

  self.lookup_labels_values[key] = labels_values
end

function Histogram:collect()
  if next(self.counts) == nil then
    return {}
  end

  local lines = {}
  tinsert(lines, '# HELP ' .. self.name .. ' ' .. escape_string(self.help))
  tinsert(lines, '# TYPE ' .. self.name .. ' histogram')
  for key, buckets_values in pairs(self.counts) do
    local labels_values = self.lookup_labels_values[key]
    local labels_values_with_le = {tunpack(labels_values)}
    local le_pos = #labels_values_with_le + 1

    for i, upper in ipairs(self.buckets) do
      labels_values_with_le[le_pos] = metric_to_string(upper)
      tinsert(lines, format_sample(self.name .. '_bucket', self.labels, labels_values_with_le, buckets_values[i]))
    end
    tinsert(lines, format_sample(self.name .. '_count', self.labels, labels_values, buckets_values[#buckets_values]))
    tinsert(lines, format_sample(self.name .. '_sum', self.labels, labels_values, self.sums[key]))
  end

  return lines
end

------------
--- APIS ---
------------

local METRIC_SUFFIXES = {
  summary = { '_sum', '_count' },
  histogram = { '_bucket', '_sum', '_count' }
}

function CALL.register(_, name, help, metric_type, labels, ...)
  local Collector = assert(collectors_types[metric_type], "Unknown metric type: " .. metric_type)
  assert(collectors_registry[name] == nil, "Metric name is already used: " .. name)
  local suffixes = METRIC_SUFFIXES[metric_type]
  if suffixes ~= nil then
    for _, s in ipairs(suffixes) do
      local metric_name = name .. s
      assert(used_metric_names[metric_name] == nil, "Metric name is already used: " .. metric_name)
    end
  end

  local collector = Collector.new(name, help, labels, ...)
  collectors_registry[name] = collector
  used_metric_names[name] = true
  if suffixes ~= nil then
    for _, s in ipairs(suffixes) do
      local metric_name = name .. s
      used_metric_names[metric_name] = true
    end
  end

  return name
end

function CALL.unregister(_, name)
  local collector = collectors_registry[name]
  if collector ~= nil then
    collectors_registry[name] = nil
    local suffixes = METRIC_SUFFIXES[collector.type]
    if suffixes ~= nil then
      for _, s in ipairs(suffixes) do
        local metric_name = name .. s
        used_metric_names[metric_name] = nil
      end
    end
  end
end

function CALL.collect()
  local ret = {}
  for _, collector in pairs(collectors_registry) do
    for _, m in ipairs(collector:collect()) do
      tinsert(ret, m)
    end
    tinsert(ret, '')
  end

  return tconcat(ret, "\n")
end

function SEND.submit(_, name, method, ...)
  local collector = assert(collectors_registry[name], 'Unknown collector name: ' .. name)
  local f = assert(collector[method], 'Not supported collector method: ' .. method)
  f(collector, ...)
end

function SEND.serve(_, fd)
  httpd.write_response(sockethelper.writefunc(fd), 200, CALL.collect())
  socket.close(fd)
end

function CALL.serve(_, fd)
  httpd.write_response(sockethelper.writefunc(fd), 200, CALL.collect())
end

skynet.start(function()
  generic_lua_dispatcher.dispatch(skynet, CALL, SEND)
end)
