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
  local slogger = require 'xi.slogger'
  local prometheus = require 'sx.prometheus'

  skynet.start(function()
    xpcall(function()
      local counter = prometheus.counter('test', 'Test counter', { 'testcase' }):register()
      counter:inc(1, { "integration" })
      counter:inc(10, { "integration" })
      counter:inc(10, { "second" })

      metrics = prometheus.collect()
      print(metrics)
      assert(metrics:match('test{testcase="integration"} 11'), "The counter should be 11")
      assert(metrics:match('test{testcase="second"} 10'), "The second counter should be 10")
      counter:unregister()

      local gauge = prometheus.gauge('test_gauge', 'Test gauge', { 'testcase' }):register()
      gauge:inc(1, { 'integration' })
      gauge = prometheus.gauge('test_gauge')
      gauge:dec(3, { 'integration' })
      metrics = prometheus.collect()
      print(metrics)
      assert(metrics:match('test_gauge{testcase="integration"} %-2'), "The gauge should be -2, but got: \n" .. metrics)
      gauge:set(5, { 'integration' })
      metrics = prometheus.collect()
      print(metrics)
      assert(metrics:match('test_gauge{testcase="integration"} 5'), "The gauge should be 5, but got: \n" .. metrics)
      gauge:unregister()

      local summary = prometheus.summary('test_summary', 'Test summary', { 'testcase' }):register()
      summary:observe(5, {'integration'})
      summary:observe(15, {'integration'})
      metrics = prometheus.collect()
      print(metrics)
      assert(metrics:match('test_summary_sum{testcase="integration"} 20'), "The summary sum should be 20, but got: \n" .. metrics)
      assert(metrics:match('test_summary_count{testcase="integration"} 2'), "The summary count should be 2, but got: \n" .. metrics)
      summary:unregister()

      local histogram = prometheus.histogram('test_histogram', 'Test histogram', { 'testcase' }, {0.05, 0.5}):register()
      histogram:observe(0.02, { 'integration' })
      histogram:observe(0.05, { 'integration' })
      histogram:observe(0.5, { 'integration' })
      histogram:observe(1, { 'integration' })
      metrics = prometheus.collect()
      print(metrics)
      assert(metrics:match('test_histogram_bucket{testcase="integration",le="0.05"} 2'))
      assert(metrics:match('test_histogram_bucket{testcase="integration",le="0.5"} 3'))
      assert(metrics:match('test_histogram_bucket{testcase="integration",le="%+Inf"} 4'))
      assert(metrics:match('test_histogram_count{testcase="integration"} 4'), "The histogram count should be 4, but got: \n" .. metrics)
      assert(metrics:match('test_histogram_sum{testcase="integration"} 1.57'), "The histogram sum should be 1.57, but got: \n" .. metrics)

      histogram:unregister()
    end, function(err)
      io.stderr:write(debug.traceback("Failed: " .. err, 2).."\n")
      os.exit(1)
    end)

    os.exit(0)
  end)
end

