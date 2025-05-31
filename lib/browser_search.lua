local query = table.concat(arg, " ", 1)
local query_s = table.concat(arg, "%20", 1)

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
    os.execute("xdg-open "..query)
    -- if it dont match, just search it
else os.execute('xdg-open https://searx.be/search?q='..query_s)
end

