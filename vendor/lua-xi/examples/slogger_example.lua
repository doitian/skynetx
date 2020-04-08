local slogger = require 'xi.slogger'
local encode = require "inspect"

local root_logger = slogger.create({
  name = 'root',
  encode = encode
})

root_logger:info('hello, %s', 'world')
---> { name = 'root', msg = 'hello, world' }

xpcall(function() error("failed") end, slogger.xpcall_handler(root_logger))

root_logger:debug(function()
  return { msg = 'hello, function' }
end)
---> { name = 'root', msg = 'hello, function' }

local child_logger = root_logger:child({
  name = 'child',
  user = 1
})

child_logger:info({
  msg = 'from child',
  charge = 6
})
---> { name = 'child', user = 1, msg = 'from child', charge = 6 }

