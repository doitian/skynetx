--- 应用 helloworld 入口.
--
-- @module service.start_helloworld

local skynet = require "skynet"
local logger = require "sx.logger"

skynet.start(function()
  logger:info("Hello, World")
  os.exit(true)
end)
