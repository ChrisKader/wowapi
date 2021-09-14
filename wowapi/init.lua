local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end
local STUB_TABLE = function() return {} end
local STUB_PREDICATE = function() return false end
local function getFn(t)
  if t.status == 'unimplemented' then
    assert(t.impl == nil)
    if t.outputs == 'n' then
      return STUB_NUMBER
    elseif t.outputs == 't' then
      return STUB_TABLE
    elseif t.outputs == 'b' then
      return STUB_PREDICATE
    elseif t.outputs == 'z' or t.outputs == nil then
      return UNIMPLEMENTED
    else
      error(('invalid output signature %q on %q'):format(t.outputs, t.name))
    end
  elseif t.status == 'stub' then
    return assert(t.impl)
  else
    error(('invalid status %q on %q'):format(t.status, t.name))
  end
end

return function(dir)
  local fns = {}
  for f in require('lfs').dir(dir) do
    if f:sub(-4) == '.lua' then
      local fn = f:sub(1, -5)
      local t = dofile(dir .. '/' .. f)
      assert(fn == t.name, ('invalid name %q in %q'):format(t.name, f))
      local bfn = getFn(t)
      local impl = not t.inputs and bfn or function(...)
        -- Ignore trailing nils for our purposes.
        local last = select('#', ...)
        while last > 0 and (select(last, ...)) == nil do
          last = last - 1
        end
        local sig = ''
        for i = 1, last do
          local ty = type((select(i, ...)))
          if ty == 'string' then
            sig = sig .. 's'
          elseif ty == 'number' then
            sig = sig .. 'n'
          else
            error(('invalid argument %d of type %q to %q'):format(i, ty, fn))
          end
        end
        if type(t.inputs) == 'string' then
          assert(sig == t.inputs, ('invalid arguments to %q, expected %q, got %q'):format(fn, t.inputs, sig))
        elseif type(t.inputs) == 'table' then
          local ok = false
          for _, x in ipairs(t.inputs) do
            ok = ok or sig == x
          end
          assert(ok, ('invalid arguments to %q, expected one of %q, got %q'):format(fn, table.concat(t.inputs), sig))
        else
          error(('invalid inputs type on %q'):format(fn))
        end
        return bfn(...)
      end
      local dot = fn:find('%.')
      if dot then
        local p = fn:sub(1, dot-1)
        fns[p] = fns[p] or {}
        fns[p][fn:sub(dot+1)] = impl
      else
        fns[fn] = impl
      end
    end
  end
  return fns
end
