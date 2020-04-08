--- Szudzik Pairing Function.
--
-- See [paper]( http://szudzik.com/ElegantPairing.pdf and discussion http://stackoverflow.com/a/13871379/667158?stw=2 )

local msqrt = math.sqrt
local mfloor = math.floor

--- 将两个非负整数一一映射到一个非负整数.
--
-- 生成的数的比两个数中较大的数的平方稍大。
local function pair(x, y)
  if x < y then
    return x + y * y
  else
    return x * x + x + y
  end
end

--- 方法 @{pair} 的逆操作.
local function unpair(z)
  local zsf = mfloor(msqrt(z))
  local zsfzsf = zsf * zsf
  local z_zsfzsf = z - zsfzsf

  if z_zsfzsf < zsf then
    return z_zsfzsf, zsf
  else
    return zsf, z_zsfzsf - zsf
  end
end

--- @export
return {
  pair = pair,
  unpair = unpair
}
