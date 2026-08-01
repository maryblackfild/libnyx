libNyx = libNyx or {}
libNyx.version = "1.0.0"

if SERVER then
    AddCSLuaFile("libnyx/lib/rndx.lua")
    AddCSLuaFile("libnyx/lib/libnyx_components.lua")
    AddCSLuaFile("libnyx/lib/libnyx_maindemo.lua")
    AddCSLuaFile("libnyx/lib/libnyx_liquidglass.lua")
    MsgC(Color(120, 200, 255), "[libNyx] ", Color(120, 220, 120), "Loaded v1.0.0 (server)\n")
    return
end

libNyx.rndx = include("libnyx/lib/rndx.lua")
include("libnyx/lib/libnyx_components.lua")
include("libnyx/lib/libnyx_maindemo.lua")
include("libnyx/lib/libnyx_liquidglass.lua")


if libNyx.ui.installGlobalMenuSkin then
    libNyx.ui.installGlobalMenuSkin()
end

if libNyx.ui.installGlobalNotificationSkin then
    local function installNotificationSkin()
        if not libNyx or not libNyx.ui or not libNyx.ui.installGlobalNotificationSkin then return end
        if libNyx.ui.installGlobalNotificationSkin() then
            hook.Remove("Think", "libNyx.installNotificationSkin")
            hook.Remove("InitPostEntity", "libNyx.installNotificationSkin")
        end
    end

    hook.Add("InitPostEntity", "libNyx.installNotificationSkin", installNotificationSkin)
    hook.Add("Think", "libNyx.installNotificationSkin", installNotificationSkin)
end

MsgC(Color(120, 200, 255), "[libNyx] ", Color(120, 220, 120), "Loaded v1.0.0 (client)\n")
