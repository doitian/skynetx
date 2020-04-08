-- vim: ft=lua:
project = 'SkynetX v2.0.43'
description = 'SkynetX 是基于 skynet 组件集，方便更快速的用 skynet 搭建起游戏后端'
full_description = '详细文档请查看@{README.md|这里}.'
title = 'SkynetX'
dir = 'html'
-- style = '!fixed'
use_markdown_titles = true
examples = { '../vendor/lua-xi/examples' }
topics = { '../README.md', '.' }
format = 'markdown'
sort_modules = true
package = 'sx'
file = {
  '../src/sx',
  '../src/xi',
  '../src/ccmix',
  '../csrc/myrand.c',
  '../csrc/isaac.c',
  '../cservice/sx_syslog.c',
  exclude = {
    '../src/xi/version.lua'
  }
}
