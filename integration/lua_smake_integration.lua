#!sx lua

local cjson = require 'cjson'
local inspect = require 'inspect'
local openssl = require 'openssl'

local base64encode = require 'crypt'.base64encode
local cipher = require 'openssl.cipher'

print(cjson.encode({ test = 1 }))
print(inspect(cjson.decode('{"foo":"bar"}')))

local aes = cipher.new('AES-256-CBC')
aes:encrypt(string.rep("x", 32), string.rep("a", 16), false)
print(base64encode(aes:final(string.rep("f", 16))))
