function fileExists(pth)
local f = io.open(pth, "r")
    if f then
    f:close()
        return true
    else 
        return false
    end 
end

local home = os.getenv("HOME")
local dir = home.."/.orca/cache/"

if #arg == 0 then
    print("Usage: luajit player_search.lua <query>")
    os.exit(1)
end

local fArgs = {}

for i = 1, #arg do
        table.insert(fArgs, arg[i])
end

if #fArgs == 0 then
    print("Usage: luajit player_search <query>")
    os.exit(1)
end

local query = table.concat(fArgs, " ")
local handle = io.popen("yt-dlp --get-id --continue 'ytsearch:" .. query .. "'")
local vidId = handle:read("*l")
handle:close()

if not vidId or vidId == "" then
    print("No video ID found.")
    os.exit(1)
end

local filePath = dir .. vidId .. ".mp4"
if fileExists(filePath) then
    print("skipping download -- file exists")
else
    print("Downloading video with ID:", vidId)
    os.execute("mkdir -p '" .. dir .. "'")
    local dl = "yt-dlp -o '" .. filePath .. "' --continue --merge-output-format mp4 'ytsearch:" .. query .. "'"
    os.execute(dl)
end

-- no config b/c the user, is dumb
-- input-default-bindings=no b/c the program is dumb
-- remove --really-quiet to get output back
os.execute("mpv --no-video  --really-quiet --input-default-bindings=no --input-vo-keyboard=no --no-config --term-playing-msg=played --keep-open=no --input-ipc-server=/tmp/mpvsocket '" .. filePath .. "'")
