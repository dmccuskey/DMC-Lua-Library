

--====================================================================--
-- Imports

local Objects = require 'lua_objects'

-- https://gist.github.com/BlackBulletIV/4084042
-- http://fw-geekycoder.blogspot.com/2012/04/how-to-implement-doubly-linked-list-in.html
-- http://www.lua.org/pil/11.4.html

--====================================================================--
-- Setup, Constants

local inheritsFrom = Objects.inheritsFrom
local ObjectBase = Objects.ObjectBase


local createNode( data )
  local o  {
    _prev=nil,
    _next=nil,
    data=data
  }
  return o
end


local list = inheritsFrom( ObjectBase )
list.NAME = "User Session Class"

function list:_init( params )
  self.first=nil
  self.last=nil
  self.length=0
end

function list:push( data )
  local o = createNode( data )

  if self.last then
    self.last._next = o
    o._prev = self.last
    self.last = o
  else
    -- this is the first node
    self.first = o
    self.last = o
  end

  self.length = self.length + 1
end

function list:unshift( data )
  local o = createNode( data )
  if self.first then
    self.first._prev = o
    o._next = self.first
    self.first = o
  else
    self.first = o
    self.last = o
  end

  self.length = self.length + 1
end

function list:insert(t, after)
  if after then
    if after._next then
      after._next._prev = t
      t._next = after._next
    else
      self.last = t
    end

    t._prev = after
    after._next = t
    self.length = self.length + 1
  elseif not self.first then
    -- this is the first node
    self.first = t
    self.last = t
  end
end

function list:pop()
  if not self.last then return end
  local ret = self.last

  if ret._prev then
    ret._prev._next = nil
    self.last = ret._prev
    ret._prev = nil
  else
    -- this was the only node
    self.first = nil
    self.last = nil
  end

  self.length = self.length - 1
  return ret
end

function list:shift()
  if not self.first then return end
  local ret = self.first

  if ret._next then
    ret._next._prev = nil
    self.first = ret._next
    ret._next = nil
  else
    self.first = nil
    self.last = nil
  end

  self.length = self.length - 1
  return ret
end

function list:remove(t)
  if t._next then
    if t._prev then
      t._next._prev = t._prev
      t._prev._next = t._next
    else
      -- this was the first node
      t._next._prev = nil
      self._first = t._next
    end
  elseif t._prev then
    -- this was the last node
    t._prev._next = nil
    self._last = t._prev
  else
    -- this was the only node
    self._first = nil
    self._last = nil
  end

  t._next = nil
  t._prev = nil
  self.length = self.length - 1
end

local function iterate(self, current)
  if not current then
    current = self.first
  elseif current then
    current = current._next
  end

  return current
end

function list:iterate()
  return iterate, self, nil
end

return list
