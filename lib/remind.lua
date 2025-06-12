for k, v in pairs(arg) do
    print(k, v)
end
local hr = arg[1]
local min = arg[2]
local alert = table.concat(arg, " ", 3)

if not hr or not min then
    print("Usage: lua script.lua <hour>:<minute> <msg>")
    os.exit(1)
end

local now = os.date("*t")
local target_time = os.time({
    year = now.year,
    month = now.month,
    day = now.day,
    hour = hr,
    min = min,
    sec = 0,
})

if target_time <= os.time() then
    target_time = target_time + 24 * 60 * 60
end

local seconds_to_wait = os.difftime(target_time, os.time())
os.execute("sleep " .. tonumber(seconds_to_wait))

local function cmd_exist(cmd)
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

if cmd_exist("notify-send") then
    os.execute(string.format('notify-send "Alert from orca" "%s"', alert))
elseif cmd_exist("xmessage") then
    os.execute(string.format('xmessage "%s."', alert))
else
    print("No notification tool found, tried xmessage and notify-send")
end
