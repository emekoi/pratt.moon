--
-- meta
--
-- Copyright (c) 2017 emekoi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
-- Warning
--
-- This library modifies global state.

-- https://github.com/TheJoshua974/Utils/blob/master/luaUtils.lua
-- https://github.com/luastoned/lua-essentials/blob/master/essentials.lua
-- https://stackoverflow.com/questions/3781816/accessing-type-metatables-lua
-- https://www.lua.org/manual/5.1/manual.html#pdf-setmetatable
-- https://www.lua.org/manual/5.1/manual.html#pdf-getmetatable
-- https://www.lua.org/manual/5.1/manual.html#pdf-debug.setmetatable
-- https://www.lua.org/manual/5.1/manual.html#pdf-debug.getmetatable
-- http://lua-users.org/wiki/HiddenFeatures
local meta, dostring

meta = {
  string: debug.getmetatable("")
  string_cache: {}
  func: {}
}

unpack or= table.unpack

--------------------------------------------------
-- strings
--------------------------------------------------

dostring = (str) -> return assert((loadstring or load)(str))()

meta.string.__index = (idx) =>
  if (string[idx])
    return string[idx]
  else
    idx = tonumber(idx)
    if not idx or idx > string.len(@) then return nil
    if (tonumber(idx))
      return string.sub(@, idx, idx)


meta.string.__call = (...) =>
  if not meta.string_cache[@]
    args, body = @\match([[^([%w,_ ]-)%->(.-)$]])
    assert(args and body, "bad string lambda")
    s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
    meta.string_cache[@] = dostring(s)
  if (...)
    return meta.string_cache[@](...)
  else
    return meta.string_cache[@]

meta.string.__add = (str) =>
  return @ .. tostring(str)

meta.string.__mod = (var) =>
  if var == nil then return @
  if type(var) ~= "table"
    error("expected table got " + type(var))
  f = (x) ->
    return tostring(var[x] or var[tonumber(x)] or "{" .. x .. "}")
  return (string.gsub(@, "{(.-)}", f))

meta.string.__pow = (var) =>
  if type(var) == "string"
    return string.format(@, var)
  elseif type(var) == "table"
    return string.format(@, unpack(var))
  else
    error("expected table or table got " + type(var))


-- local _print = print
-- print = function(...)
--   local info = debug.getinfo(2, "Sl")
--   _print(info.short_src + ":" + info.currentline, ...)
--   -- _print(...)
-- end

--------------------------------------------------
-- functions
--------------------------------------------------

meta.func.__add = (fn) =>
  return (...) ->
    ret = { @(...), fn(...) }
    return ret


meta.func.__mul = (t) =>
  if "number" == type t
    for i = 1, t do
      @()

debug.setmetatable ->, meta.func
