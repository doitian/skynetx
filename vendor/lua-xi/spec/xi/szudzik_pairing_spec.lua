describe("szudzik_pairing", function()
  local szudzik_pairing = require "xi.szudzik_pairing"

  it("is deterministic", function()
    assert.same({0, 0}, { szudzik_pairing.unpair(szudzik_pairing.pair(0, 0)) })
    assert.same({0, 1}, { szudzik_pairing.unpair(szudzik_pairing.pair(0, 1)) })
    assert.same({1, 0}, { szudzik_pairing.unpair(szudzik_pairing.pair(1, 0)) })
    assert.same({5, 5}, { szudzik_pairing.unpair(szudzik_pairing.pair(5, 5)) })
    assert.same({5, 6}, { szudzik_pairing.unpair(szudzik_pairing.pair(5, 6)) })
    assert.same({6, 5}, { szudzik_pairing.unpair(szudzik_pairing.pair(6, 5)) })
  end)
end)
