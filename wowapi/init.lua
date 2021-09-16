local function loadApis(dir)
  local apis = {}
  for f in require('lfs').dir(dir) do
    if f:sub(-4) == '.lua' then
      local fn = f:sub(1, -5)
      local api = dofile(dir .. '/' .. f)
      assert(fn == api.name, ('invalid name %q in %q'):format(api.name, f))
      apis[fn] = api
    end
  end
  return apis
end

local getStub = (function()
  local defaultOutputs = {
    b = 'false',
    n = '1',
    s = '\'\'',
    t = '{}',
    x = 'nil',
    z = 'nil',
    ['?'] = 'nil',
  }
  local function mkStub(sig)
    local rets = {}
    for i = 1, string.len(sig) do
      local v = defaultOutputs[sig:sub(i, i)]
      assert(v, ('invalid output signature %q'):format(sig))
      table.insert(rets, v)
    end
    return loadstring('return ' .. table.concat(rets, ', '))
  end
  local stubs = {}
  return function(sig)
    local stub = stubs[sig]
    if not stub then
      stub = mkStub(sig)
      stubs[sig] = stub
    end
    return stub
  end
end)()

local argSig = (function()
  local typeSigs = {
    boolean = 'b',
    number = 'n',
    string = 's',
    table = 't',
  }
  return function(fn, ...)
    -- Ignore trailing nils for our purposes.
    local last = select('#', ...)
    while last > 0 and (select(last, ...)) == nil do
      last = last - 1
    end
    local sig = ''
    for i = 1, last do
      local ty = type((select(i, ...)))
      local c = typeSigs[ty]
      if not c then
        error(('invalid argument %d of type %q to %q'):format(i, ty, fn))
      end
      sig = sig .. c
    end
    return sig
  end
end)()

local function checkSig(fn, apisig, fsig)
  if type(apisig) == 'string' then
    assert(fsig == apisig, ('invalid arguments to %q, expected %q, got %q'):format(fn, apisig, fsig))
  elseif type(apisig) == 'table' then
    local ok = false
    for _, x in ipairs(apisig) do
      ok = ok or fsig == x
    end
    assert(ok, ('invalid arguments to %q, expected one of %q, got %q'):format(fn, table.concat(apisig), fsig))
  else
    error(('invalid inputs type on %q'):format(fn))
  end
end

local function getFn(api)
  if api.status == 'unimplemented' then
    assert(api.impl == nil)
    return getStub(api.outputs or '')
  elseif api.status == 'stub' then
    return assert(api.impl)
  else
    error(('invalid status %q on %q'):format(api.status, api.name))
  end
end

return function(dir)
  local fns = {}
  for fn, api in pairs(loadApis(dir)) do
    local bfn = getFn(api)
    local impl = not api.inputs and bfn or function(...)
      checkSig(fn, api.inputs, argSig(fn, ...))
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
  return fns
end
