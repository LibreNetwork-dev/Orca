local source = debug.getinfo(1, "S").source
local cwd

if source:sub(1, 1) == "@" then
  local full_path = source:sub(2)
  cwd = full_path:match("^(.*[/\\])") or "./"
else
  cwd = "./"
end

package.path = cwd .. "link/?.lua;" .. package.path
package.cpath = cwd .. "link/?.so;" .. package.cpath  


local soc = require("luaSoc") -- homemade garbage 
json = require("json")  -- also homemade garbage

local paused = json.parse(soc.sendData("/tmp/mpvsocket", '{ "command": ["get_property", "pause"] }\n' ))

if paused.data then
    soc.sendData("/tmp/mpvsocket", '{"command": ["set_property", "pause", false]}\n')
 else 
    soc.sendData("/tmp/mpvsocket", '{"command": ["set_property", "pause", true]}\n')
 end
