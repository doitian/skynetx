describe("priority_queue", function()
  local priority_queue = require "xi.priority_queue"

  it("insert natural numbers", function ()
    local q = priority_queue.new()
    q:insert(1)
    q:insert(4)
    q:insert(9)

    assert.equal(q:size(), 3)
    assert.equal(q:pop(), 1)
    assert.equal(q:size(), 2)

    q:insert(5)
    q:insert(4)
    q:insert(10)
    q:insert(2)
    q:insert(11)

    assert.equal(q:size(), 7)

    assert.equal(q:top(), 2)
    assert.equal(q:pop(), 2)
    assert.equal(q:pop(), 4)
    assert.equal(q:pop(), 4)
    assert.equal(q:pop(), 5)
    assert.equal(q:pop(), 9)
    assert.equal(q:pop(), 10)

    assert.equal(q:size(), 1)
    assert.equal(q:empty(), false)

    assert.equal(q:pop(), 11)

    assert.equal(q:size(), 0)
    assert.equal(q:empty(), true)
    assert.equal(q:pop(), nil)
  end)

  it("insert negative numbers", function ()
    local q = priority_queue.new({ 4, 2, 1, 6, 3, -1 })
    q:insert(3)

    assert.equal(q:size(), 7)
    assert.equal(q:empty(), false)

    assert.equal(q:top(), -1)
    assert.equal(q:pop(), -1)
    assert.equal(q:pop(), 1)
    assert.equal(q:pop(), 2)
    assert.equal(q:pop(), 3)
    assert.equal(q:pop(), 3)
    assert.equal(q:pop(), 4)

    assert.equal(q:size(), 1)
    assert.equal(q:empty(), false)

    assert.equal(q:pop(), 6)

    assert.equal(q:size(), 0)
    assert.equal(q:empty(), true)
    assert.equal(q:pop(), nil)
  end)

  it("customized comparer", function ()
    local q = priority_queue.new({ 4, 2, 1, 6, 3, -1 }, function (lhs, rhs)
      return lhs > rhs
    end)
    q:insert(3)

    assert.equal(q:size(), 7)
    assert.equal(q:empty(), false)

    assert.equal(q:top(), 6)
    assert.equal(q:pop(), 6)
    assert.equal(q:pop(), 4)
    assert.equal(q:pop(), 3)
    assert.equal(q:pop(), 3)
    assert.equal(q:pop(), 2)
    assert.equal(q:pop(), 1)

    assert.equal(q:size(), 1)
    assert.equal(q:empty(), false)

    assert.equal(q:pop(), -1)

    assert.equal(q:size(), 0)
    assert.equal(q:empty(), true)
    assert.equal(q:pop(), nil)
  end)

  it("reset to empty queue", function ()
    local q = priority_queue.new({ 4, 2, 1, 6, 3, -1 }, function (lhs, rhs)
      return lhs > rhs
    end)
    q:insert(3)

    assert.equal(q:size(), 7)
    assert.equal(q:empty(), false)

    assert.equal(q:top(), 6)
    assert.equal(q:pop(), 6)
    assert.equal(q:pop(), 4)

    assert.equal(q:size(), 5)
    assert.equal(q:empty(), false)

    q:reset()
    assert.equal(q:size(), 0)
    assert.equal(q:empty(), true)
    assert.equal(q:pop(), nil)
  end)

  it("reset queue with new array", function ()
    local q = priority_queue.new({ 4, 2, 1, 6, 3, -1 }, function (lhs, rhs)
      return lhs > rhs
    end)
    q:insert(3)

    assert.equal(q:size(), 7)
    assert.equal(q:empty(), false)

    assert.equal(q:top(), 6)
    assert.equal(q:pop(), 6)
    assert.equal(q:pop(), 4)

    assert.equal(q:size(), 5)
    assert.equal(q:empty(), false)

    q:reset({ -2, 2, 0, 100 })
    assert.equal(q:size(), 4)
    assert.equal(q:empty(), false)
    assert.equal(q:pop(), 100)
    assert.equal(q:pop(), 2)
    assert.equal(q:pop(), 0)

    q:insert(-1)
    assert.equal(q:size(), 2)
    assert.equal(q:pop(), -1)
    assert.equal(q:pop(), -2)
    assert.equal(q:size(), 0)
    assert.equal(q:empty(), true)
    assert.equal(q:pop(), nil)
  end)

  it("insert userdatas", function ()
    local q = priority_queue.new(nil, function (lhs, rhs)
        -- campare time and priority
        for _,v in ipairs({ "time", "priority" }) do
          if lhs[v] ~= rhs[v] then
            return lhs[v] < rhs[v]
          end
        end
    end)

    local t1 = { time = 1, priority = 2 }
    q:insert(t1)
    q:insert({ time = 2, priority = 1 })
    q:insert({ time = -4, priority = 1 })
    q:insert({ time = 1, priority = 1 })
    q:insert({ time = 5, priority = 1 })
    q:insert({ time = 5, priority = 2 })

    assert.equal(q:size(), 6)
    assert.equal(q:empty(), false)

    assert.same(q:top(), { time = -4, priority = 1 })
    assert.same(q:pop(), { time = -4, priority = 1 })
    assert.same(q:pop(), { time = 1, priority = 1 })
    assert.equal(q:top(), t1)
    assert.equal(q:pop(), t1)

    assert.same(q:pop(), { time = 2, priority = 1 })
    assert.same(q:pop(), { time = 5, priority = 1 })
    assert.same(q:pop(), { time = 5, priority = 2 })

    assert.equal(q:size(), 0)
    assert.equal(q:empty(), true)
    assert.equal(q:pop(), nil)
  end)
end)
