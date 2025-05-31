local JSON = {}

local function skip_ws(str, i)
  return str:match("^[ \n\r\t]*()", i)
end

local function parse_string(str, i)
  local result = ""
  i = i + 1
  while i <= #str do
    local c = str:sub(i, i)
    if c == '"' then return result, i + 1
    elseif c == '\\' then
      local esc = str:sub(i+1, i+1)
      local map = { ['"']='"', ['\\']='\\', ['/']='/', b='\b', f='\f', n='\n', r='\r', t='\t' }
      result = result .. (map[esc] or esc)
      i = i + 2
    else
      result = result .. c
      i = i + 1
    end
  end
  error("Unclosed string")
end

local function parse_number(str, i)
  local num = str:match("^%-?%d+%.?%d*[eE]?[+-]?%d*", i)
  if not num then error("Invalid number at " .. i) end
  return tonumber(num), i + #num
end

local function parse_literal(str, i)
  if str:sub(i, i+3) == "true" then return true, i+4 end
  if str:sub(i, i+4) == "false" then return false, i+5 end
  if str:sub(i, i+3) == "null" then return nil, i+4 end
  error("Unknown literal at " .. i)
end

local function parse_array(str, i)
  local result = {}
  i = skip_ws(str, i + 1)
  if str:sub(i, i) == "]" then return result, i + 1 end
  while true do
    local val
    val, i = JSON._parse(str, i)
    result[#result + 1] = val
    i = skip_ws(str, i)
    local c = str:sub(i, i)
    if c == "]" then return result, i + 1 end
    if c ~= "," then error("Expected ',' or ']' at " .. i) end
    i = skip_ws(str, i + 1)
  end
end

local function parse_object(str, i)
  local result = {}
  i = skip_ws(str, i + 1)
  if str:sub(i, i) == "}" then return result, i + 1 end
  while true do
    local key, val
    if str:sub(i, i) ~= '"' then error("Expected string key at " .. i) end
    key, i = parse_string(str, i)
    i = skip_ws(str, i)
    if str:sub(i, i) ~= ":" then error("Expected ':' at " .. i) end
    i = skip_ws(str, i + 1)
    val, i = JSON._parse(str, i)
    result[key] = val
    i = skip_ws(str, i)
    local c = str:sub(i, i)
    if c == "}" then return result, i + 1 end
    if c ~= "," then error("Expected ',' or '}' at " .. i) end
    i = skip_ws(str, i + 1)
  end
end

function JSON._parse(str, i)
  i = skip_ws(str, i)
  local c = str:sub(i, i)
  if c == '"' then return parse_string(str, i)
  elseif c == '-' or c:match("%d") then return parse_number(str, i)
  elseif c == 't' or c == 'f' or c == 'n' then return parse_literal(str, i)
  elseif c == '[' then return parse_array(str, i)
  elseif c == '{' then return parse_object(str, i)
  else error("Unexpected character at " .. i .. ": '" .. c .. "'") end
end

function parse(str)
  local result, i = JSON._parse(str, 1)
  i = skip_ws(str, i)
  if i <= #str then error("Trailing garbage at " .. i) end
  return result
end

return JSON
