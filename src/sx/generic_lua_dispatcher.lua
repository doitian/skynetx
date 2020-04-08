--- 用于 skynet.dispatch lua 的处理函数.
--
-- 根据 session 是否为 0 自动判断是否需要返回结果.

local generic_lua_dispatcher = {}

--- 调用 skynet.dispatch lua.
--
-- 命令列表 `on_call` 和 `on_send` 使用命令名字作 key，对应的处理方法作值。处理
-- 方法接受的第一个参数是来源服务的地址，其它参数是对应的 `skynet.call`
-- 和 `skynet.send` 第 4 个参数开始的所有参数。
--
--     -- counter.lua
--     local skynet = require "skynet"
--     local generic_lua_dispatcher = require "xi.generic_lua_dispatcher"
--     local counter = 0
--     local on_send = {
--       inc = function(_, num)
--         counter = counter + (num or 1)
--       end
--     }
--     local on_call = {
--       get = function()
--         return counter
--       end
--     }
--     generic_lua_dispatcher.dispatch(skynet, on_call, on_send)
--     -- main.lua
--     local counter = skynet.newservice("counter")
--     skynet.send(counter, "lua", "inc")
--     skynet.send(counter, "lua", "inc", 10)
--     skynet.call(counter, "lua", "get") ---> 11
--
-- @param skynet skynet 对象
-- @tparam tab on_call 处理 `skynet.call` 请求的命令列表
-- @tparam tab on_send 处理 `skynet.send` 请求的命令列表
function generic_lua_dispatcher.dispatch(skynet, on_call, on_send)
  skynet.dispatch("lua", function(session, source, cmd, ...)
    local f
    if session == 0 then
      f = assert(on_send[cmd], "Unknown send cmd: " .. cmd)
      f(source, ...)
    else
      f = assert(on_call[cmd], "Unknown call cmd: " .. cmd)
      skynet.ret(skynet.pack(f(source, ...)))
    end
  end)
end

return generic_lua_dispatcher
