/***
 * 随机数发生器.
 *
 * 战斗逻辑实现需要 server 和 client 根据相同的随机种子得到完全相同的结果，由于
 * server 端可能会同时验算多场战斗，所以需要同时维护多个随机序列，故实现此文件
 * 保证 server 和 client 的随机过程完全一致。
 *
 *    local myrand = require "myrand"
 *    local generator = myrand.generator(os.time())
 *    generator() ---> Generate next random number
 *
 * 随机数范围是 0 到 32767 (包含 0 和 32767)
 *
 * - ian 2016-07-13 迁移到 Lua 5.3
 * - wangyue 2014－12-17
 * 
 * @module myrand
 */
#include <stdint.h>
#include <lauxlib.h>
#include <lua.h>

// 算法提取自 POSIX.1-2001 rand()实现
static int32_t nextRandom(lua_State *L)
{
    uint32_t seed = lua_tointeger(L, lua_upvalueindex(1));
    int32_t ret;
    seed = seed * (int32_t)1103515245 + (int32_t)12345;
    ret = (int32_t)((uint32_t)seed / (int32_t)65536) % (int32_t)32768;
    lua_pushinteger(L, ret);
    lua_pushinteger(L, seed);
    lua_replace(L, lua_upvalueindex(1));
    return 1;
}

/// 给 Lua 返回一个用来生成随机序列的函数.
//
// @function generator
// @tparam integer seed 随机种子
// @treturn function generator 每次调用返回一个 `[0, 32767]` 区间内的随机数
int32_t generator(lua_State *L)
{
    int32_t seed = (int32_t)lua_tonumber(L, 1);
    lua_pushinteger(L, seed);
    lua_pushcclosure(L, nextRandom, 1);
    return 1;
}

LUALIB_API int32_t luaopen_myrand(lua_State *L)
{
    luaL_Reg reg[] = {
        {"generator", generator},
        {NULL, NULL}
    };
    luaL_newlib(L, reg);
    return 1;
}
