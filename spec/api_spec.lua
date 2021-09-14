describe('api', function()
  local env = {
    require = require,
  }
  for f in require('lfs').dir('api') do
    if f:sub(-4) == '.lua' then
      local fn = f:sub(1, -5)
      describe(fn, function()
        local t = setfenv(loadfile('api/' .. f), env)()
        it('has the right name', function()
          assert.same(fn, t.name)
        end)
        it('has a valid status', function()
          assert.True(t.status == 'unimplemented' or t.status == 'stub')
        end)
        it('has a valid protection', function()
          assert.True(t.protection == nil or t.protection == 'hardware')
        end)
        if t.impl and t.tests then
          local impl = t.impl
          for _, test in ipairs(t.tests) do
            (test.pending and pending or it)(test.name, function()
              assert.same(test.outputs, {impl(unpack(test.inputs))})
            end)
          end
        end
      end)
    end
  end
end)
