--- 优先队列
--
-- 支持自定义比较函数

local priority_queue = {}

local function less(lhs, rhs)
  return lhs < rhs
end

-- 将制定位置的元素进行下降操作
local function sink_down(q, start_pos, end_pos, cmp)
  local itr = start_pos

  while itr <= end_pos/2 do
    local left = itr * 2
    local right = itr * 2 + 1

    local pos = (right > end_pos or cmp(q[left], q[right])) and left or right
    pos = cmp(q[itr], q[pos]) and itr or pos

    if pos == itr then
      break
    else
      q[pos], q[itr] = q[itr], q[pos]
      itr = pos
    end
  end
end

--- 将指定位置的元素进行上升操作
local function rise_up(q, pos, cmp)
  local itr = pos

  while itr > 1 do
    local parent = math.floor(itr/2)

    if cmp(q[parent], q[itr]) then
      break
    else
      q[parent], q[itr] = q[itr], q[parent]
      itr = parent
    end
  end
end

--- 建堆
local function build_heap(array, cmp)
  local size = #array

  if size < 2 then
    return
  end

  for i=math.floor(size/2),1,-1 do
    sink_down(array, i, size, cmp)
  end
end

--- 创建一个优先队列
--
-- @tparam table array 数组中的元素必须支持 camparer 进行比较，可以是 nil 或者 {}
-- @tparam function comparer 比较函数，默认是 < 操作，如果 comparer(A, B) == true，则 A 排在 B 前面
-- @treturn priority_queue q
-- @usage
--     priority_queue.new({ {time = 1}, {time = 2} }, function(lhs, rhs)
--       return lhs.time < rhs.time
--     end)
function priority_queue.new(array, comparer)
  array = array or {}
  comparer = comparer or less
  build_heap(array, comparer)

  local q = {}
  q._array = array
  q._comparer = comparer
  setmetatable(q, { __index = priority_queue })
  return q
end

--- 插入一个元素到队列中
--
-- @param value 需要支持创建队列时传入的比较操作
function priority_queue:insert(value)
  local size = self:size() + 1
  self._array[size] = value
  rise_up(self._array, size, self._comparer)
end

--- 从队列中弹出一个元素
function priority_queue:pop()
  local top = self._array[1]
  local size = self:size()

  self._array[1] = self._array[size]
  self._array[size] = nil
  sink_down(self._array, 1, size - 1, self._comparer)

  return top
end

--- 返回队列的第一个元素
--
-- @return 如果队列为空，则返回 nil
function priority_queue:top()
  return self._array[1]
end

--- 返回队列的大小
--
-- @treturn number
function priority_queue:size()
  return #self._array
end

--- 查询队列是否为空
--
-- @treturn boolean
function priority_queue:empty()
  return self:size() == 0
end

--- 重置队列
--
-- 该操作等价于用 array 和相同的 comparer 重新创建一个队列
--
-- @tparam table array
-- @see new
function priority_queue:reset(array)
  self._array = array or {}
  build_heap(self._array, self._comparer)
end

return priority_queue
