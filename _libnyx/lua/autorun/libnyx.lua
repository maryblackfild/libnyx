-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

libNyx = libNyx or {}

local function read_local_version()
    local p1,p2 = "VERSION","libnyx/VERSION"
    local v = file.Exists(p1,"GAME") and file.Read(p1,"GAME") or file.Exists(p1,"LUA") and file.Read(p1,"LUA") or file.Exists(p2,"LUA") and file.Read(p2,"LUA") or file.Exists(p2,"GAME") and file.Read(p2,"GAME") or ""
    v = tostring(v or ""):gsub("[\r\n]","")
    if v == "" then v = "0.6.7" end
    return v
end

libNyx.Version = libNyx.Version or read_local_version()

local RAW_VERSION_URL = "https://raw.githubusercontent.com/maryblackfild/libnyx/main/VERSION"
local RAW_LOADER_URL  = "https://raw.githubusercontent.com/maryblackfild/libnyx/main/lua/autorun/libnyx_loader.lua"
local HOMEPAGE        = "https://github.com/maryblackfild/libnyx"

local function norm(v) v = tostring(v or "") return (v:sub(1,1)=="v") and v:sub(2) or v end
local function say(kind,msg)
    local h = Color(120,200,255)
    local c = kind=="ok" and Color(120,220,120) or kind=="warn" and Color(255,220,120) or kind=="err" and Color(255,120,120) or Color(200,200,210)
    MsgC(h,"[libNyx] ",c,msg,"\n")
end

local function do_update_check()
    say("info","Checking for updates…")
    http.Fetch(RAW_VERSION_URL, function(body)
        local remote = tostring(body or ""):gsub("[\r\n]","")
        if remote=="" then return say("err","Update check failed.") end
        local a,b = norm(libNyx.Version), norm(remote)
        if a==b then
            say("ok",("Up-to-date ✓ (latest: %s)"):format(remote))
        else
            say("warn",("Update available ✱ installed %s → latest %s"):format(libNyx.Version, remote))
            say("info","Get it: "..HOMEPAGE)
        end
    end, function()
        http.Fetch(RAW_LOADER_URL, function(body)
            local remote = tostring(body or ""):match('libNyx%.Version%s*=%s*["\']([%w%._%-]+)["\']')
            if not remote or remote=="" then return say("err","Update check failed.") end
            local a,b = norm(libNyx.Version), norm(remote)
            if a==b then
                say("ok",("Up-to-date ✓ (latest: %s)"):format(remote))
            else
                say("warn",("Update available ✱ installed %s → latest %s"):format(libNyx.Version, remote))
                say("info","Get it: "..HOMEPAGE)
            end
        end, function() say("err","Update check failed.") end)
    end)
end

if SERVER then
    AddCSLuaFile("libnyx/lib/rndx.lua")
    AddCSLuaFile("libnyx/lib/libnyx_components.lua")
    AddCSLuaFile("libnyx/lib/libnyx_maindemo.lua")
    include("libnyx/lib/rndx.lua")
    timer.Simple(0, function() say("info",("Loaded v%s (server)"):format(libNyx.Version)) do_update_check() end)
    return
end

libNyx.rndx = libNyx.rndx or include("libnyx/lib/rndx.lua")
_G.RNDX     = _G.RNDX     or libNyx.rndx
include("libnyx/lib/libnyx_components.lua")
include("libnyx/lib/libnyx_maindemo.lua")
timer.Simple(0, function() say("info",("Loaded v%s (client)"):format(libNyx.Version)) do_update_check() end)


-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
