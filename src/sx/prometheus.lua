--- Prometheus client skynet 实现.
--
-- 所有的 Metrics 应该在服务器启动的时候先全部创建好并创建。
--
--     local prometheus = require "sx.prometheus"
--     prometheus.gauge('skynet_online_users', '在线玩家数量'):register()
--     prometheus.counter('skynet_exceptions_count', '异常数量'):register()
--     prometheus.histogram('skynet_request_duration_seconds', {'profile_id', 'request_status'}):register()
--
-- 在需要记录统计数值的服务中在去创建相同名字的 Metric，注意不要重复注册，会出错，而且只需要传 name 就可以了，其它都不用了
--
--     # in agent.lua
--     local prometheus = require "sx.prometheus"
--     local metric_online_users = prometheus.gauge('skynet_online_users')
--
--     local init(...)
--       metric_online_users:inc()
--       ...
--     end
--
--     local on_exit()
--       metric_online_users:dec()
--     end
--
-- 如果要在 xpcall 中的 error handler 中使用，因为不能在 error handler 中调用一些 skynet 方法，最好在服务启动的地方先调用一次 `prometheus.default_registry()`

local skynet = require "skynet"

local sgsub = string.gsub
local tsort = table.sort
local tinsert = table.insert

local prometheus = {}

local INF = math.huge
local DEFAULT_BUCKETS = { 0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, INF }

local METRIC_NAME_PATTERN = '[a-zA-Z_:][a-zA-Z0-9_:]*'
local METRIC_LABEL_NAME_PATTERN = '[a-zA-Z_][a-zA-Z0-9_]*'
local RESERVED_METRIC_LABEL_NAME_PATTERN = '__.*'

local function fully_match(s, pattern)
  return sgsub(s, pattern, '') == ''
end

local function is_valid_name(name)
  return fully_match(name, METRIC_NAME_PATTERN)
end

local function is_valid_label_name(name)
  return fully_match(name, METRIC_LABEL_NAME_PATTERN) and not fully_match(name, RESERVED_METRIC_LABEL_NAME_PATTERN)
end

local REGISTRY
local DEFAULT_REGISTRIES

--- 获得默认注册服务.
function prometheus.default_registry()
  if REGISTRY == nil then
    REGISTRY = skynet.uniqueservice("sx_prometheus_registry")
  end
  return REGISTRY
end
local default_registry = prometheus.default_registry

--- 获得 Regstiry 所有的数据.
-- @treturn string metrics
function prometheus.collect(registry)
  return skynet.call(registry or default_registry(), 'lua', 'collect')
end

--- 把 socket 转给 Regstiry 直接返回结果.
--
-- 因为是异步操作，不要在该方法后关闭 socket。Registry 会发回结果后关闭连接。
function prometheus.serve_http(socket, registry)
  return skynet.send(registry or default_registry(), 'lua', 'serve', socket)
end

--- 把 socket 转给 Regstiry 直接返回结果.
--
-- 同步等待发回结果，需要调用者自己关闭 socket
function prometheus.serve_http_and_wait(socket, registry)
  return skynet.call(registry or default_registry(), 'lua', 'serve', socket)
end

local function each_registry(collector)
  if next(collector._registries) then
    return pairs(collector._registries)
  else
    if DEFAULT_REGISTRIES == nil then
      local registry = default_registry()
      DEFAULT_REGISTRIES = { [registry] = registry }
    end
    return pairs(DEFAULT_REGISTRIES)
  end
end

local Collector = {}
Collector.__index = Collector

local Counter = setmetatable({_type = 'counter'}, Collector)
Counter.__index = Counter

--- 创建一个 counter.
--
-- Counter 用来计算，比如请求数量，异常数量等等
--
-- @tparam string name Metric 名字
-- @tparam string help Metric 用途说明
-- @tparam[opt] tab labels 标签名字数组
-- @treturn Counter
function prometheus.counter(name, help, labels)
  return Counter:new(name, help, labels)
end

local Gauge = setmetatable({_type = 'gauge'}, Collector)
Gauge.__index = Gauge

--- 创建一个 gauge.
--
-- Gauge 用来记录一个可以自由变化的数值，可以用来记录在线人数等等。
--
-- @tparam string name Metric 名字
-- @tparam string help Metric 用途说明
-- @tparam[opt] tab labels 标签名字数组
-- @treturn Gauge
function prometheus.gauge(name, help, labels)
  return Gauge:new(name, help, labels)
end

local Summary = setmetatable({_type = 'summary'}, Collector)
Summary.__index = Summary

--- 创建一个 summary.
--
-- Summary 同时记录观测值的出现数量和总和。可以用来同时统计请求数量和总用时。
--
-- @tparam string name Metric 名字
-- @tparam string help Metric 用途说明
-- @tparam[opt] tab labels 标签名字数组
-- @treturn Gauge
function prometheus.summary(name, help, labels)
  return Summary:new(name, help, labels)
end

local Histogram = setmetatable({_type = 'histogram'}, Collector)
Histogram.__index = Histogram

--- 创建一个 histogram.
--
-- Histogram 除了 summary 统计的信息，还会根据 buckets 分别统计落入不同区间的观测值的数量。
--
-- 每个 Bucket 指定了上限，所有观测值小于或者等于上限的 buckets 都会加 1。
--
-- @tparam string name Metric 名字
-- @tparam string help Metric 用途说明
-- @tparam[opt] tab labels 标签名字数组
-- @tparam[opt] tab buckets 每个区间的上限
-- @treturn Gauge
function prometheus.histogram(name, help, labels, buckets)
  return Histogram:new(name, help, labels):buckets(buckets)
end

--- Counter, Gauge, Summary, Histogram 共享的方法.
-- @type Collector

function Collector:new(name, help, labels)
  assert(name ~= nil and name ~= "", "Require metric name")
  assert(is_valid_name(name), "Invalid metric name: " .. name)
  labels = labels or {}
  return setmetatable({
    _name = name,
    _help = help,
    _labels = labels,
    _registries = {},
    _type = self._type,
  }, self)
end

--- 设置标签名.
--
-- 只有在调用 register 注册之前设置才有用
--
-- @tparam tab labels 标签名数组
-- @return collector 返回自己
function Collector:labels(labels)
  labels = labels or {}
  for _, l in ipairs(labels) do
    assert(is_valid_label_name(l), "Invalid label name: " .. l)
  end
  self._labels = labels
  return self
end

--- 注册 metric.
--
-- 注册后才会把数据真正记录下来.
--
-- @param[opt] registry 注册服务，缺省使用默认的注册服务
-- @return collector 返回自己
function Collector:register(registry)
  assert(self._help ~= nil and self._help ~= "", "Require metric help")
  for _, l in ipairs(self._labels) do
    assert(is_valid_label_name(l), "Invalid label name: " .. l)
  end
  registry = registry or default_registry()
  if self._registries[registry] == nil then
    skynet.call(registry, 'lua', 'register', self._name, self._help, self._type, self._labels, self._buckets)
    self._registries[registry] = registry
  end

  return self
end

--- 取消注册 metric.
--
-- @param[opt] registry 注册服务，缺省使用默认的注册服务
-- @return collector 返回自己
function Collector:unregister(registry)
  registry = registry or default_registry()
  if self._registries[registry] ~= nil then
    skynet.call(registry, 'lua', 'unregister', self._name)
    self._registries[registry] = nil
  end

  return self
end


--- Counter metric.
-- @type Counter

--- 增长 Counter 的计数.
-- @tparam number num 非负数，可以是浮点数
-- @tparam tab labels_values 标签的值数组
function Counter:inc(num, labels_values)
  for _, registry in each_registry(self) do
    skynet.send(registry, 'lua', 'submit', self._name, 'inc', num or 1, labels_values)
  end
  return self
end

--- Gauge metric.
-- @type Gauge

--- 增加 Gauge 的数量.
-- @tparam number num 变化数量
-- @tparam tab labels_values 标签的值数组
function Gauge:inc(num, labels_values)
  for _, registry in each_registry(self) do
    skynet.send(registry, 'lua', 'submit', self._name, 'inc', num or 1, labels_values)
  end
  return self
end

--- 减少 Gauge 的数量.
-- @tparam number num 变化数量
-- @tparam tab labels_values 标签的值数组
function Gauge:dec(num, labels_values)
  for _, registry in each_registry(self) do
    skynet.send(registry, 'lua', 'submit', self._name, 'dec', num or 1, labels_values)
  end
  return self
end

--- 将 Gauge 数量设置为指定值.
-- @tparam number num 指定 Gauge 的值
-- @tparam tab labels_values 标签的值数组
function Gauge:set(num, labels_values)
  for _, registry in each_registry(self) do
    skynet.send(registry, 'lua', 'submit', self._name, 'set', num or 1, labels_values)
  end
  return self
end

--- Summary metric.
-- @type Summary

--- 记录一个 Summary 的观察值.
-- @tparam number num 观察值
-- @tparam tab labels_values 标签的值数组
function Summary:observe(num, labels_values)
  assert(num ~= nil, "Require num")
  for _, registry in each_registry(self) do
    skynet.send(registry, 'lua', 'submit', self._name, 'observe', num, labels_values)
  end

  return self
end

--- Histogram metric.
-- @type Histogram

--- 自定义 Histogram 的 buckets.
-- 只有在调用 register 注册之前设置才有用
-- @tparam tab buckets 每个 buckets 的上限组成的数组.
-- @return histogram 返回自己
function Histogram:buckets(buckets)
  if buckets == nil then
    self._buckets = DEFAULT_BUCKETS
  else
    tsort(buckets)
    if buckets[#buckets] ~= INF then
      tinsert(buckets, INF)
    end
    self._buckets = buckets
  end

  return self
end

--- 记录一个 Histogram 的观察值.
-- @tparam number num 观察值
-- @tparam tab labels_values 标签的值数组
function Histogram:observe(num, labels_values)
  assert(num ~= nil, "Require num")
  for _, registry in each_registry(self) do
    skynet.send(registry, 'lua', 'submit', self._name, 'observe', num, labels_values)
  end

  return self
end

return prometheus
