# Lua Xi v0.0.12

纯 Lua 库集合。

## 库列表

- moment: 基础时间库，支持时区和字符串间双向的转换，并支持不同时区。
- slogger: 输出结构化数据日志 (Struct LOGGER)
- szudzik\_pairing: 用来将一对非负整数一一映射到一个非负整数上
- priority\_queue: 优先队列（堆）


## 安装和更新

把 src/xi 目录放到程序 lua path 目录下就可以了，更新下载最新的代码替换掉 xi 目录就可以了。

## 贡献

- 使用 LDoc 进行文档注释，参考已有文件中的注释
- 通过 luacheck 0.17 的检测
- 需要在 spec 目录中添加测试，测试使用 [busted](https://olivinelabs.com/busted/)
- 项目已经配置了 CI，提交 MR 如果没通过 CI 请根据错误提示修改
