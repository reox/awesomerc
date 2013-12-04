local io = io
local math = math
local naughty = naughty
local beautiful = beautiful
local tonumber = tonumber
local tostring = tostring
local print = print
local pairs = pairs

module("battery")

local limits = {{20, 5},
          {10, 3},
          { 5, 1},
            {0}}

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end


function get_bat_state (adapter)
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local filename = "charge"
    local sta = fsta:read()
    -- sometimes after hibernation the filenames changes...
    if not file_exists("/sys/class/power_supply/"..adapter.."/"..filename.."_now") then
        filename = "energy"
    end

    local fcur = io.open("/sys/class/power_supply/"..adapter.."/"..filename.."_now")
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/"..filename.."_full")
    local facp = io.popen("acpi -b")
    local cur = fcur:read()
    local cap = fcap:read()
    local acp = facp:read()
    fcur:close()
    fcap:close()
    fsta:close()
    facp:close()
    local battery = math.floor(cur * 100 / cap)
    local idx = -1 
    if sta:match("Charging") then
        dir = 1
        idx = acp:find('until')
    elseif sta:match("Discharging") then
        dir = -1
        idx = acp:find('remaining')
    else
        dir = 0
        battery = ""
    end
    local time = acp:sub(idx - 8, idx - 5)
    return battery, dir, time
end

function getnextlim (num)
    for ind, pair in pairs(limits) do
        lim = pair[1]; step = pair[2]; nextlim = limits[ind+1][1] or 0
        if num > nextlim then
            repeat
                lim = lim - step
            until num > lim
            if lim < nextlim then
                lim = nextlim
            end
            return lim
        end
    end
end


function batclosure (adapter)
    local nextlim = limits[1][1]
    return function ()
        local prefix = "⚡"
        local battery, dir, time = get_bat_state(adapter)
        if dir == -1 then
            dirsign = "↓"
            prefix = "Bat: "
            prefix = prefix .. time
            local to = 30 - battery
            if battery <= nextlim then
                naughty.notify({title = "⚡ Beware! ⚡",
                            text = "Battery charge is low ( ⚡ "..battery.."%) "..time.." remaining!",
                            timeout = to,
                            position = "bottom_right",
                            fg = beautiful.fg_focus,
                            bg = beautiful.bg_focus
                            })
                nextlim = getnextlim(battery)
            end
        elseif dir == 1 then
            dirsign = "↑"
            nextlim = limits[1][1]
        else
            dirsign = "FULL"
        end
        if dir ~= 0 then battery = battery.."%" end
        return "[ "..prefix.." "..dirsign..battery..dirsign.." ]"
    end
end
