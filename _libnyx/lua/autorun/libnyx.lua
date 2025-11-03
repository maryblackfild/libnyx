-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

-- lua/autorun/libnyx_loader.lua
libNyx = libNyx or {}

local function read_local_version()
    local p1,p2 = "VERSION","libnyx/VERSION"
    local v = file.Exists(p1,"GAME") and file.Read(p1,"GAME") or file.Exists(p1,"LUA") and file.Read(p1,"LUA") or file.Exists(p2,"LUA") and file.Read(p2,"LUA") or file.Exists(p2,"GAME") and file.Read(p2,"GAME") or ""
    v = tostring(v or ""):gsub("[\r\n]","")
    if v == "" then v = "0.0.0" end
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
    AddCSLuaFile("libnyx/lib/libnyx_liquidglass.lua")
    AddCSLuaFile("libnyx/lib/libnyx_maindemo.lua")
    timer.Simple(0, function() say("info",("Loaded v%s (server)"):format(libNyx.Version)) do_update_check() end)
    return
end

local function hasFont(f)
    local n="__nyx_font_test"
    surface.CreateFont(n,{font=f,size=16,weight=500,extended=true})
    surface.SetFont(n)
    local w,h=surface.GetTextSize("Aa")
    return (w or 0)>0 and (h or 0)>0
end

local function precreate_alias_fonts()
    local base = hasFont("Manrope") and "Manrope" or "Tahoma"
    for sz=10,200 do
        local name=("libNyx.%s.%d"):format(base, sz)
        surface.CreateFont(name,{font=base,size=sz,weight=(sz>=28) and 500 or 400,extended=true})
    end
    for sz=10,60 do
        local name=("libNyx.UI.%d"):format(sz)
        surface.CreateFont(name,{font=base,size=sz,weight=(sz>=28) and 500 or 400,extended=true})
    end
end

local boot = {}
local function include_all_once()
    if not boot.rndx then
        libNyx.rndx = include("libnyx/lib/rndx.lua")
        _G.RNDX = _G.RNDX or libNyx.rndx
        boot.rndx = true
    end
    if not boot.components then
        include("libnyx/lib/libnyx_components.lua")
        boot.components = true
    end
    if not boot.demo then
        include("libnyx/lib/libnyx_maindemo.lua")
        boot.demo = true
    end
    if not boot.liquid then
        include("libnyx/lib/libnyx_liquidglass.lua")
        boot.liquid = true
    end
end

local function ready_gate_try()
    local UI = _G.libNyx and _G.libNyx.UI
    local ok = UI and UI.Draw and UI.Components and UI.Components.CreateSlider and RNDX
    if not ok then return false end
    return true
end

local function run_after_include()
    precreate_alias_fonts()
    if _G.libNyx and _G.libNyx.UI and _G.libNyx.UI.InstallGlobalMenuSkin then _G.libNyx.UI.InstallGlobalMenuSkin() end
    if _G.libNyx and _G.libNyx.UI and _G.libNyx.UI.InstallGlobalNotificationSkin then _G.libNyx.UI.InstallGlobalNotificationSkin() end
end

local trying=0
local function wait_until_ready()
    trying = trying + 1
    if ready_gate_try() then
        libNyx.Ready = true
        return
    end
    if trying < 240 then timer.Simple(0, wait_until_ready) else say("warn","Init gate timed out; some UI may be unavailable.") end
end

local function client_bootstrap()
    include_all_once()
    run_after_include()
    wait_until_ready()
end

local function gamemode_init_bridge()
    if libNyx.__booted then return end
    libNyx.__booted = true
    client_bootstrap()
end

hook.Add("OnGamemodeLoaded","libNyx.Loader.GMInit",gamemode_init_bridge)
hook.Add("Initialize","libNyx.Loader.Init",gamemode_init_bridge)
hook.Add("InitPostEntity","libNyx.Loader.InitPostEntity",function() if not libNyx.Ready then client_bootstrap() end end)
hook.Add("OnReloaded","libNyx.Loader.Reload",function()
    boot = {}
    libNyx.Ready = false
    client_bootstrap()
end)

timer.Simple(0, function()
    if not libNyx.__booted then gamemode_init_bridge() end
    say("info",("Loaded v%s (client)"):format(libNyx.Version))
    do_update_check()
end)

-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
