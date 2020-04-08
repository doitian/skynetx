describe("myrand", function()
  local myrand = require "myrand"
  local generator = myrand.generator

  describe("generator", function()
    it("generates same sequence using the same seed", function()
      local g1 = generator(1234)
      local g2 = generator(1234)
      assert.equal(g1(), g2())
      assert.equal(g1(), g2())
    end)

    it("generates different sequences using different seeds", function()
      local g1 = generator(1234)
      local g2 = generator(1235)
      assert.not_equal(g1(), g2())
      assert.not_equal(g1(), g2())
    end)
  end)
end)
