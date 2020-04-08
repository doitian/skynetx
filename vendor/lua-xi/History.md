v0.0.12 / 2017-01-19
==================

  * 新功能：autoload xi
  
  
```
local xi = require "xi"
local now = xi.moment.now()
```

v0.0.11 / 2016-12-18
==================

  * 新模块: 优先队列 priority\_queue
  * 新模块：整数对映射 szudzik\_pairing

v0.0.10 / 2016-12-12
==================

  * slogger: 支持稀疏数组

v0.0.9 / 2016-12-07
==================

  * slogger: 输出可读的 time，去掉 ts

v0.0.8 / 2016-12-03
===================

  * moment: 日期计算扩展，见 moment 文档中 xi.moment.datetime 小节
  * moment: 增加方法 `inspect` 方便调试
  * moment: 增加方法 `from_date`, `time_from_date`, `expand_date` 方便日期计算
  * moment: at 第一个参数不传默认为当前时间

v0.0.7 / 2016-12-02
===================

  * moment: 修复日期显示错误

v0.0.6 / 2016-11-29
===================

  * export moment.time
  * delete inspect.lua
