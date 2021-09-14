#!/bin/bash
set -e
eval $(.lua/bin/luarocks path)
.lua/bin/luacheck -q --no-color api spec wowapi
.lua/bin/busted --defer-print
