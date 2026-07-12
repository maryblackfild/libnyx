
libNyx = libNyx or {}
local RAW_VERSION_URL = "https://raw.githubusercontent.com/maryblackfild/libnyx/main/VERSION"
local HOMEPAGE        = "https://github.com/maryblackfild/libnyx"
local function fnNormalizeVersion( sVersion )
    sVersion = tostring( sVersion or "" )
    if sVersion:sub( 1, 1 ) == "v" then
        return sVersion:sub( 2 )
    end
    return sVersion
end
local function fnReadLocalVersion()
    local tPaths   = { "VERSION", "libnyx/VERSION" }
    local tDomains = { "GAME", "LUA" }
    local sVersion = ""

    for _, sPath in ipairs( tPaths ) do
        for _, sDomain in ipairs( tDomains ) do
            if file.Exists( sPath, sDomain ) then
                sVersion = file.Read( sPath, sDomain )
                break
            end
        end
        if sVersion ~= "" then break end
    end

    sVersion = tostring( sVersion ):gsub( "[\r\n]", "" )
    return sVersion == "" and "0.0.0" or sVersion
end

libNyx.Version = libNyx.Version or fnReadLocalVersion()


local function fnSay( sKind, sMessage )
    local clrHeader = Color( 120, 200, 255 )
    local clrBody
    if sKind == "ok" then
        clrBody = Color( 120, 220, 120 )
    elseif sKind == "warn" then
        clrBody = Color( 255, 220, 120 )
    elseif sKind == "err" then
        clrBody = Color( 255, 120, 120 )
    else
        clrBody = Color( 200, 200, 210 )
    end
    MsgC( clrHeader, "[libNyx] ", clrBody, sMessage, "\n" )
end


local function fnCheckForUpdates()
    fnSay( "info", "Checking for updates..." )
    http.Fetch( RAW_VERSION_URL,
        function( sBody )
            local sRemote = tostring( sBody ):gsub( "[\r\n]", "" )
            if sRemote == "" then
                fnSay( "err", "Update check failed: empty response." )
                return
            end
            local sLocal      = fnNormalizeVersion( libNyx.Version )
            local sRemoteVer  = fnNormalizeVersion( sRemote )
            if sLocal == sRemoteVer then
                fnSay( "ok", string.format( "Up-to-date (latest: %s)", sRemote ) )
            else
                fnSay( "warn", string.format( "Update available! installed %s → latest %s",
                    libNyx.Version, sRemote ) )
                fnSay( "info", "Download: " .. HOMEPAGE )
            end
        end,
        function( sError )
            fnSay( "err", "Update check failed: " .. tostring( sError ) )
        end
    )
end

if SERVER then
    timer.Simple( 0, function()
        fnSay( "info", string.format( "Loaded v%s (server)", libNyx.Version ) )
        fnCheckForUpdates()
    end )
    return
end


local bBooted            = false
local bFontsPrecreated   = false
local nInitAttempts      = 0
local MAX_INIT_ATTEMPTS  = 240
local tLoadedModules     = {} 

local function fnPrecreateFonts()
    if bFontsPrecreated then return end
    local sBaseFont = "Manrope"
    surface.CreateFont( "__nyx_font_test", {
        font     = sBaseFont,
        size     = 16,
        weight   = 500,
        extended = true
    } )
    surface.SetFont( "__nyx_font_test" )
    local nW, nH = surface.GetTextSize( "Aa" )
    if not ( nW > 0 and nH > 0 ) then
        sBaseFont = "Tahoma"
    end

    for nSize = 10, 100 do
        local sName1 = string.format( "libNyx.%s.%d", sBaseFont, nSize )
        local sName2 = string.format( "libNyx.UI.%d", nSize )
        local tFontData = {
            font     = sBaseFont,
            size     = nSize,
            weight   = ( nSize >= 28 ) and 500 or 400,
            extended = true
        }
        surface.CreateFont( sName1, tFontData )
        surface.CreateFont( sName2, tFontData )
    end
    bFontsPrecreated = true
end

local function fnIncludeModule( sPath, sKey, tTarget )
    if tLoadedModules[sPath] then return end
    local bOk, result = pcall( include, sPath )
    if bOk then
        tTarget[sKey] = result
        tLoadedModules[sPath] = true
    else
        fnSay( "err", string.format( "Failed to load module %s: %s", sPath, tostring( result ) ) )
    end
end

local function fnLoadClientModules()
    fnIncludeModule( "libnyx/lib/rndx.lua", "rndx", libNyx )
    _G.RNDX = libNyx.rndx or _G.RNDX

    if not tLoadedModules["components"] then
        include( "libnyx/lib/libnyx_components.lua" )
        tLoadedModules["components"] = true
    end
    if not tLoadedModules["demo"] then
        include( "libnyx/lib/libnyx_maindemo.lua" )
        tLoadedModules["demo"] = true
    end
    if not tLoadedModules["liquid"] then
        include( "libnyx/lib/libnyx_liquidglass.lua" )
        tLoadedModules["liquid"] = true
    end
end

local function fnIsClientReady()
    local UI = libNyx.UI
    local bUIReady = UI and UI.Draw and UI.Components and UI.Components.CreateSlider
    local bRNDXReady = libNyx.rndx and type( libNyx.rndx ) == "table"
    return bUIReady and bRNDXReady
end

local function fnApplyUISkins()
    if libNyx.UI and libNyx.UI.InstallGlobalMenuSkin then
        libNyx.UI.InstallGlobalMenuSkin()
    end
    if libNyx.UI and libNyx.UI.InstallGlobalNotificationSkin then
        libNyx.UI.InstallGlobalNotificationSkin()
    end
end

local function fnClientBootstrap()
    if bBooted then return end
    bBooted = true

    fnLoadClientModules()
    fnPrecreateFonts()

    local function fnPollReady()
        nInitAttempts = nInitAttempts + 1
        if fnIsClientReady() then
            libNyx.Ready = true
            fnApplyUISkins()
            fnSay( "ok", "Client initialized successfully." )
            return
        elseif nInitAttempts < MAX_INIT_ATTEMPTS then
            timer.Simple( 0, fnPollReady )
        else
            fnSay( "warn", "Initialization timed out; some UI may be unavailable." )
        end
    end
    fnPollReady()
end

hook.Add( "OnGamemodeLoaded",  "libNyx.Loader.GMInit",       fnClientBootstrap )
hook.Add( "Initialize",        "libNyx.Loader.Init",         fnClientBootstrap )
hook.Add( "InitPostEntity",    "libNyx.Loader.InitPostEntity", function()
    if not libNyx.Ready then
        fnClientBootstrap()
    end
end )
hook.Add( "OnReloaded",        "libNyx.Loader.Reload", function()
    -- Full reset on reload
    tLoadedModules = {}
    bBooted          = false
    libNyx.Ready     = false
    bFontsPrecreated = false
    nInitAttempts    = 0
    fnClientBootstrap()
end )

timer.Simple( 0, function()
    if not bBooted then
        fnClientBootstrap()
    end
    fnSay( "info", string.format( "Loaded v%s (client)", libNyx.Version ) )
    fnCheckForUpdates()
end )
