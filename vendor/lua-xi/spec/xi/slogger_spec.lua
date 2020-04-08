describe("slogger", function()
  local slogger = require 'xi.slogger'
  local L = slogger.LEVELS
  local identity = function(x) return x end
  local last_log
  local root = slogger.create({ name = 'root', level = 'info', encode = identity, printer = function(x) last_log = x end })

  before_each(function() last_log = nil end)

  describe("log", function()
    it("prints string as msg", function()
      root:info('foo')
      assert.equal('foo', last_log.msg)
    end)

    it("formats when there are extra arguments", function()
      root:info('hello, %s', 'world')
      assert.equal('hello, world', last_log.msg)
    end)

    it("prints table", function()
      root:info({ msg = 'foo', from = 'func' })
      assert.equal('foo', last_log.msg)
      assert.equal('func', last_log.from)
    end)

    it("prints function return table", function()
      root:info(function() return { msg = 'foo', from = 'func' } end)
      assert.equal('foo', last_log.msg)
      assert.equal('func', last_log.from)
    end)
  end)

  describe("logger level", function()
    it("prints when level is less verbose than logger level", function()
      root:warn('foo')
      assert.equal(L.warn, last_log.level)
      assert.equal('foo', last_log.msg)
    end)

    it("skipps when level is more verbose than logger level", function()
      root:debug('hello')
      assert.is_nil(last_log)
    end)
  end)

  describe("child", function()
    it("inherits parent context", function()
      root:child():info('foo')
      assert.equal('root', last_log.name)
    end)

    it("overrides parent context", function()
      root:child({ name = 'child' }):info('foo')
      assert.equal('child', last_log.name)
    end)

    it("adds new context field", function()
      root:child({ child = true }):info('foo')
      assert.truthy(last_log.child)
    end)

    it("overrides parent config", function()
      root:child({ level = 'warn' }):info('foo')
      assert.is_nil(last_log)
      -- but parent is unchanged
      root:info('foo')
      assert.is_not_nil(last_log)
    end)
  end)
end)
