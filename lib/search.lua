local query = table.concat(arg, " ", 1)
local query_s = table.concat(arg, "%20", 1)

function openUrl(url)
  local is_windows = package.config:sub(1,1) == '\\'
  local function commandExists(cmd)
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result ~= ''
  end

  if is_windows then
    -- Windows (because maybe just in case)
    os.execute('start "" "' .. url .. '"')
  else
    -- linux (not universial but idgas atp)
    if commandExists("xdg-open") then
      os.execute('xdg-open "' .. url .. '" &')
    elseif commandExists("open") then
      -- macOS  (because maybe just in case)
      os.execute('open "' .. url .. '" &')
    else
      print("Could not open url.")
    end
  end
end

--ilovestackoverflowilovestackoverflow
function qran(str)
    str = str:match("^%s*(.-)%s*$")

    if str == "" then
      return "empty"
    end
    if str:match("^[a-z]+://[%w%.%-_%%]+[%w%p]*$") then
      return "url"
    end
  
    if str:match("^localhost:?%d*/?.*") or str:match("^127%.0%.0%.1:?%d*/?.*") then
      return "url"
    end
  
    if str:match("^%w[%w%-%.]*%.%a%a+/?[%w%p]*$") then
      return "url"
    end
  
    if str:find(" ") or str:find("[?&=]") then
      return "query"
    end
  
    return "unknown"  
end
print(qran(query))
if qran(query) == "url" then
  openUrl(query)
    -- if it dont match, just search it
else openUrl('https://searx.be/search?q='..query_s)
end

