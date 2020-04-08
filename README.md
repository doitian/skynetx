# SkynetX v2.0.43

## 快速开始

    # 创建项目 helloworld
    sx new helloworld
    # 启动 skynet 应用
    cd helloworld
    sx skynet boot/helloworld.lua
    # 创建新的 skynet 应用
    sx new-app server
    sx skynet boot/server.lua
    # 执行 Lua
    sx lua

查看 `sx help completions` 如何启用命令行自动补全.

## 文档

SkynetX (简称 sx) 是对 skynet 的扩展集

- 一次安装后可以运行多个 skynet 项目，实现 skynet 和项目的分离
- 提供常用 lua 库和 skynet 服务
- 提供脚本方便管理 skynet 项目

更多的文档可以通过 `make doc` 生成。

## 安装

### 编译安装

编译也需要先安装 openssl。

执行下面命令编译后运行其中的 `bin/sx` 即可

    make all

为方便使用可以把 `bin` 目录加到环境变量的 `PATH` 中，或者执行下面的命令安装到系统的 `/usr/local` 目录下：

    make install

运行下面的命令检查是否安装成功：

    sx

如果安装了多个版本，`sx` 不会被覆盖。新安装的版本可以带上版本号运行，比如 `sx2.0`


要卸载请执行:

    # 卸载当前版本
    make uninstall
    # 卸载 2.0 版本
    make VERSION=2.0 uninstall
    # 卸载全部版本
    make uninstall-all

也可以手动删除 `/usr/local/lib/skynetx` 目录和 `/usr/local/bin` 下的 `sx`, `sx2.0` 等可执行程序。
