-- local util = require('wowless.util')
return {
  name = 'SecureCmdOptionParse',
  inputs = 's',
  outputs = 's?s?',
  status = 'stub',
  impl = function(s)
    -- TODO resurrect this
    -- return util.strtrim((util.strsplit(';', s)))
    return s
  end,
  tests = {
    {
      name = 'empty string',
      inputs = {''},
      outputs = {''},
    },
    {
      name = 'command with no action',
      inputs = {'/hello'},
      outputs = {'/hello'},
    },
    {
      name = 'command with semicolons',
      inputs = {'/a b;c'},
      outputs = {'/a b'},
      pending = true,
    },
    {
      name = 'command with semicolons and space',
      inputs = {'/a   b   ;c'},
      outputs = {'/a   b'},
      pending = true,
    },
    {
      name = 'command with target and no action',
      inputs = {'/hello [@Alice]'},
      outputs = {'', 'Alice'},
      pending = true,
    },
  },
}
