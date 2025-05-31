local cwd = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.cpath = cwd .. "link/?.so;" .. package.cpath

local soc = require("luaSoc") 

soc.sendData("/tmp/mpvsocket", '{"command": ["pause"]}\n')

