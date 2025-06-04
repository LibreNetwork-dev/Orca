args_fl = table.concat(arg, " ", 1)

-- wayland
local wayland = os.execute("which wl-copy > /dev/null")
if wayland then
    local f = io.popen("wl-copy", "w")
    f:write(args_fl)
    f:close()
    return
end

-- x11
os.execute("echo '" .. args_fl:gsub("'", "'\\''") .. "' | xclip -selection clipboard")