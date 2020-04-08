v2.0.38 / 2017-08-31
==================

  * sx.moment 不再使用 skynet.time()

v2.0.37 / 2017-08-23
==================

  * LOGGER 配置中的 `__GIT_REV__` 添加日期方便定位和排序

v2.0.36 / 2017-08-20
==================

  * isaac: a better random number generator

v2.0.35 / 2017-05-25
==================

  * Fix prometheus `serve_http_and_wait`

v2.0.34 / 2017-05-25
==================

  * prometheus: `serve_http_and_wait`

v2.0.33 / 2017-05-15
====================

  * Bump to v2.0.33
  * 支持把当前的日志文件链接到当前目录方便查看
  * 支持使用 git 自动获取当前的版本号

v2.0.32 / 2017-03-15
====================

  * Skynet 升级到 b00b006

v2.0.31 / 2017-01-19
====================

  * alias ccmix.logger
  * Braid: Update mirror 'vendor/lua-xi' to 'v0.0.12'

v2.0.30 / 2016-12-23
==================

  * 优化代码，减少 C Boundary 错误

v2.0.29 / 2016-12-19
==================

  * prometheus: 监控客户端

v2.0.28 / 2016-12-18
==================

  * lua.xi: 更新到 v0.0.11
  * bin/sx: 可以通过环境变量 `LUA_PATH` 和 `LUA_CPATH` 添加额外路径

v2.0.27 / 2016-12-12
====================

  * sx.logger: 传稀疏数组的时候不报错
  * sx\_syslog: 修复 syslog 参数不生效的错误

v2.0.26 / 2016-12-08
====================

  * sx\_syslog: 修复退出回调在初始化之前被调用 segment fault 的错误

v2.0.25 / 2016-12-08
==================

  * sx\_syslog: progname 指针必须在 closelog 之前都有效

v2.0.24 / 2016-12-07
==================

  * Braid: lua-xi 升级到 v0.0.9，去掉 ts 换成 time
  * syslog: 使用 . 分隔 syslog 的 logger 名
  * sx-pplog: 修复月份显示

v2.0.23 / 2016-12-06
==================

  * fix: pplog 解析很长的日志会失败

v2.0.22 / 2016-12-05
==================

  * 自动补全

v2.0.21 / 2016-12-03
====================

  * Braid: 升级 'vendor/lua-xi' 到 v0.0.8
  * sx pplog: 增加命令让 JSON 日志可读
  * bin/sx: -f .env 漏掉了 shift

v2.0.20 / 2016-11-29
====================

  * Braid: 升级 'vendor/lua-xi' 到 'v0.0.6'
  * sx.logger: 在实际写第一条 log 的时候再去调用 skynet.getenv
  * sx.moment, sx.logger: 在非 skynet 环境（比如单元测试）也可以使用
  * 模板: make test 使用 sx exec 执行并添加 spec 到 lua path 中

v2.0.19 / 2016-11-28
====================

  * 新命令 `sx integration`
  * `sx verison` 中返回平台信息和 skynet 版本
