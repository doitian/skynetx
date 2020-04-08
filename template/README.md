# $PROJECT_NAME v0.0.0

本项目使用 SkynetX $SX_VERSION 创建。

## 运行

配置通过环境变量，也可以通过 .env 文件。把 example.env 复制成 .env 进行修改。

启动服务

    sx skynet boot/server.lua

## 测试

测试需要使用系统的 lua 5.3 安装 busted 和 luacheck，Mac OS X 可以使用
Homebrew。注意 busted 需要安装 github 上的最新版本，默认的版本和 skynet
有冲突。

    brew install homebrew/versions/lua53
    luarocks-5.3 install luacheck
    luarocks-5.3 --server=http://luarocks.org/dev install busted scm-0

运行静态检测和单元测试，测试编写请查看 [busted 文档](https://olivinelabs.com/busted/)

    make check test

集成测试编写请查看 `sx help integration`

    make SX_DB_TEST_URL=redis://127.0.0.1:6379/15 integration

## 文档

项目使用 [ldoc](https://stevedonovan.github.io/ldoc/manual/doc.md.html)
生成文档，项目 [lua-xi](https://github.com/doitian/lua-xi)
有很多例子可以参考。如果通过 luarocks 安装 ldoc，建议也安装 scm 版本

    luarocks-5.3 --server=http://luarocks.org/dev install ldoc scm-2
