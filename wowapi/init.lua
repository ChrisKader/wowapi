local stubs = {}

local defaults = {
  b = 'false',
  n = '1',
  s = '\'\'',
  t = '{}',
  x = 'nil',
  z = 'nil',
}

local function getFn(t)
  if t.status == 'unimplemented' then
    assert(t.impl == nil)
    local sig = t.outputs or ''
    local stub = stubs[sig]
    if not stub then
      local rets = {}
      for i = 1, string.len(sig) do
        local v = defaults[sig:sub(i, i)]
        assert(v, ('invalid output signature %q on %q'):format(sig, t.name))
        table.insert(rets, v)
      end
      stub = loadstring('return ' .. table.concat(rets, ', '))
      stubs[sig] = stub
    end
    return stub
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
