local indir, outdir = unpack(arg)
local lfs = require('lfs')
local pf = require('pl.file')
local docs = {}
local docdir = indir .. '/Interface/AddOns/Blizzard_APIDocumentation'
for f in lfs.dir(docdir) do
  if f:sub(-4) == '.lua' then
    pcall(setfenv(loadfile(docdir .. '/' .. f), {
      APIDocumentation = {
        AddDocumentationTable = function(_, t)
          docs[f] = t
        end,
      }
    }))
  end
end
local enum do
  local env = {}
  setfenv(loadfile(indir .. '/Interface/GlobalEnvironment.lua'), env)()
  enum = assert(env.Enum)
end
lfs.mkdir(outdir)
local types = {
  bool = 'b',
  number = 'n',
  string = 's',
  table = 't',
}
local tables = {
  Constants = 'n',
  Enumeration = 'n',
  Structure = 't',
}
local tys = {}
-- First pass for types.
for _, t in pairs(docs) do
  for _, ty in ipairs(t.Tables or {}) do
    assert(tys[ty.Name] == nil)
    tys[ty.Name] = assert(tables[ty.Type], ty.Type)
  end
end
for f, t in pairs(docs) do
  if t.Name then
    assert(t.Type == 'System', f)
    for _, fn in ipairs(t.Functions or {}) do
      assert(fn.Type == 'Function', f)
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. fn.Name
      local inputs = ''
      local firstDefault = nil
      for i, a in ipairs(fn.Arguments or {}) do
        local c = types[a.Type] or tys[a.Type] or (enum[a.Type] and 'n')
        if not c then
          print('unknown type ' .. a.Type)
          c = '?'
        end
        firstDefault = firstDefault or (a.Default and i)
        inputs = inputs .. c
      end
      if firstDefault then
        local s = '{'
        for i = firstDefault, inputs:len() do
          s = s .. ' \'' .. inputs:sub(1, i-1) .. '\','
        end
        inputs = s .. ' \'' .. inputs .. '\' }'
      else
        inputs = '\'' .. inputs .. '\''
      end
      local outputs = ''
      for _, r in ipairs(fn.Returns or {}) do
        local c = types[r.Type] or tys[r.Type] or (enum[r.Type] and 'n')
        if not c then
          print('unknown type ' .. r.Type)
          c = '?'
        end
        outputs = outputs .. c
      end
      pf.write(outdir .. '/' .. name .. '.lua', ([[
return {
  name = '%s',
  status = 'unimplemented',
  inputs = %s,
  outputs = '%s',
}
]]):format(name, inputs, outputs))
    end
  else
    assert(t.Tables, f)
  end
end