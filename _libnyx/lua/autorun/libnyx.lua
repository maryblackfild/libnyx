-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
libNyx = libNyx or {}

libNyx.Version = libNyx.Version or "0.0.0"

libNyx.Update = libNyx.Update or {
    enabled = true,
    url_raw_version = "https://raw.githubusercontent.com/maryblackfild/libnyx/main/VERSION",
    homepage = "https://github.com/maryblackfild/libnyx",
    cache_ttl_sec = 1800,
    last_remote = nil,
    last_checked_at = 0,
    last_status = nil
}

local C_HDR = Color(120,200,255)
local C_DIM = Color(190,190,200)
local C_OK  = Color(120,220,120)
local C_WARN= Color(255,220,120)
local C_ERR = Color(255,120,120)

local function LogC(...)
    MsgC(C_HDR, "[libNyx] ", C_DIM, ..., "\n")
end

local function LogStatus(kind, msg)
    local col = (kind == "ok" and C_OK) or (kind == "warn" and C_WARN) or (kind == "err" and C_ERR) or C_DIM
    MsgC(C_HDR, "[libNyx] ", col, msg, "\n")
end

local function trim(s)
    if not isstring(s) then return "" end
    return string.Trim(string.gsub(s, "[\r\n]", ""))
end

local function parse_version_from_body(body)
    body = trim(body or "")
    if body == "" then return nil end
    if string.sub(body, 1, 1) == "{" and util and util.JSONToTable then
        local ok = util.JSONToTable(body)
        if istable(ok) and isstring(ok.version) then return trim(ok.version) end
    end
    local v = string.match(body, "([%d%.%-]+)")
    return v and trim(v) or nil
end

local function split_semver(v)
    v = trim(v or "0.0.0")
    local core, tag = string.match(v, "^([%d%.]+)%-(.+)$")
    core = core or v
    local parts = {}
    for n in string.gmatch(core, "(%d+)") do parts[#parts+1] = tonumber(n) or 0 end
    parts[1] = parts[1] or 0
    parts[2] = parts[2] or 0
    parts[3] = parts[3] or 0
    return parts, tag
end

local function semver_cmp(a, b)
    local A, Atag = split_semver(a)
    local B, Btag = split_semver(b)
    for i = 1, 3 do
        if A[i] ~= B[i] then return (A[i] < B[i]) and -1 or 1 end
    end
    if (Atag or "") == (Btag or "") then return 0 end
    if Atag and not Btag then return -1 end
    if Btag and not Atag then return 1 end
    return (Atag < Btag) and -1 or (Atag > Btag and 1 or 0)
end

local function http_get(url, on_ok, on_fail)
    if HTTP then
        HTTP({
            url = url,
            method = "GET",
            headers = { ["Cache-Control"] = "no-cache" },
            success = function(code, body, hdrs)
                if code == 200 and body then on_ok(body, code, hdrs) else on_fail(("HTTP %s"):format(tostring(code))) end
            end,
            failed = function(err) on_fail(err or "HTTP failed") end
        })
    elseif http and http.Fetch then
        http.Fetch(url,
            function(body) if body and body ~= "" then on_ok(body, 200, {}) else on_fail("empty body") end end,
            function(err) on_fail(err or "http.Fetch failed") end,
            { ["Cache-Control"] = "no-cache" }
        )
    else
        on_fail("No HTTP module available")
    end
end

function libNyx.CheckForUpdates(force, cb)
    local U = libNyx.Update
    if not U or U.enabled == false then if cb then cb("disabled") end return end
    local enabled_realm = true
    if SERVER then
        local sv = GetConVar and GetConVar("sv_libnyx_update_check")
        if sv and sv:GetBool() == false then enabled_realm = false end
    else
        local cl = GetConVar and GetConVar("cl_libnyx_update_check")
        if cl and cl:GetBool() == false then enabled_realm = false end
    end
    if not enabled_realm then if cb then cb("disabled") end return end
    local now = RealTime and RealTime() or CurTime()
    if not force and U.last_checked_at and (now - (U.last_checked_at or 0) < (U.cache_ttl_sec or 1800)) then
        if cb then cb(U.last_status or "cached", U.last_remote) end
        return
    end
    local url = U.url_raw_version
    if not isstring(url) or url == "" then U.last_status = "error" if cb then cb("error") end return end
    http_get(url, function(body)
        local remote = parse_version_from_body(body)
        U.last_checked_at = now
        if not remote then U.last_status = "error" if cb then cb("error") end return end
        U.last_remote = remote
        local cmp = semver_cmp(libNyx.Version, remote)
        if cmp == 0 then U.last_status = "ok" if cb then cb("ok", remote) end
        elseif cmp < 0 then U.last_status = "older" if cb then cb("older", remote) end
        else U.last_status = "ahead" if cb then cb("ahead", remote) end end
    end, function(err)
        U.last_checked_at = now
        U.last_status = "offline"
        if cb then cb("offline", nil, err) end
    end)
end

local function OnLoadedBanner(realm)
    LogC(("Loaded v%s (%s)"):format(libNyx.Version, realm))
    if libNyx.Update and libNyx.Update.enabled ~= false then
        LogC("Checking for updates…")
        libNyx.CheckForUpdates(false, function(status, remote)
            if status == "ok" then
                LogStatus("ok", ("Up-to-date ✓  (latest: %s)"):format(remote))
            elseif status == "older" then
                LogStatus("warn", ("Update available ✱  installed %s → latest %s"):format(libNyx.Version, remote or "?"))
                if libNyx.Update.homepage and libNyx.Update.homepage ~= "" then LogC("Get it: ", libNyx.Update.homepage) end
            elseif status == "ahead" then
                LogStatus("ok", ("You are on a newer/dev build (%s > %s)"):format(libNyx.Version, remote or "?"))
            elseif status == "offline" then
                LogStatus("warn", "Could not reach GitHub (offline). Will cache & retry later.")
            elseif status == "disabled" then
                LogStatus("warn", "Auto-update check disabled by ConVar.")
            else
                LogStatus("err", "Update check failed.")
            end
        end)
    end
end

concommand.Add("libnyx_version", function(ply, cmd, args)
    local U = libNyx.Update or {}
    local remote = U.last_remote or "—"
    local ago = (U.last_checked_at and RealTime and (RealTime() - U.last_checked_at)) or nil
    LogC(("Installed: %s | Last remote: %s%s"):format(libNyx.Version, tostring(remote), ago and (" (checked "..math.floor(ago).."s ago)") or ""))
end)

concommand.Add("libnyx_check_update", function(ply, cmd, args)
    LogC("Forcing update check…")
    libNyx.CheckForUpdates(true, function(status, remote)
        if status == "ok" then
            LogStatus("ok", ("Up-to-date ✓  (latest: %s)"):format(remote))
        elseif status == "older" then
            LogStatus("warn", ("Update available ✱  installed %s → latest %s"):format(libNyx.Version, remote or "?"))
            if libNyx.Update.homepage and libNyx.Update.homepage ~= "" then LogC("Get it: ", libNyx.Update.homepage) end
        elseif status == "ahead" then
            LogStatus("ok", ("You are on a newer/dev build (%s > %s)"):format(libNyx.Version, remote or "?"))
        elseif status == "offline" then
            LogStatus("warn", "Could not reach GitHub (offline).")
        elseif status == "disabled" then
            LogStatus("warn", "Auto-update check disabled by ConVar.")
        else
            LogStatus("err", "Update check failed.")
        end
    end)
end)

if SERVER then
    if not ConVarExists("sv_libnyx_update_check") then
        CreateConVar("sv_libnyx_update_check", "1", FCVAR_ARCHIVE, "Enable libNyx server update checks")
    end
else
    if not ConVarExists("cl_libnyx_update_check") then
        CreateClientConVar("cl_libnyx_update_check", "1", true, false, "Enable libNyx client update checks")
    end
end

if SERVER then
    AddCSLuaFile("libnyx/lib/rndx.lua")
    AddCSLuaFile("libnyx/lib/libnyx_components.lua")
    AddCSLuaFile("libnyx/lib/libnyx_maindemo.lua")
    include("libnyx/lib/rndx.lua")
    timer.Simple(1, function() OnLoadedBanner("server") end)
    return
end

libNyx.rndx = libNyx.rndx or include("libnyx/lib/rndx.lua")
_G.RNDX     = _G.RNDX     or libNyx.rndx
include("libnyx/lib/libnyx_components.lua")
include("libnyx/lib/libnyx_maindemo.lua")
timer.Simple(0, function() OnLoadedBanner("client") end)


-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
