-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

if SERVER then
    AddCSLuaFile()
    return
end

local libNyx = libNyx or {}
libNyx.UI = libNyx.UI or {}
_G.libNyx = libNyx

local RNDX = include("libnyx/lib/rndx.lua")
if not (libNyx.UI and libNyx.UI.Draw and libNyx.UI.Components) then
    include("libnyx/lib/libnyx_components.lua")
end

local Style      = libNyx.UI.Style
local Components = libNyx.UI.Components

local GRAD_PALETTE = {
    Color( 90,160,255),
    Color(255,125,155),
    Color(120,220,160),
    Color(255,200,120),
    Color(170,120,255),
    Color(120,200,255),
}
local function PalettePick(key)
    key = tostring(key or "")
    local sum = 0
    for i = 1, #key do sum = sum + key:byte(i) end
    local idx = (sum % #GRAD_PALETTE) + 1
    return GRAD_PALETTE[idx]
end

local showcase
function libNyx.UI.OpenShowcase()
    if IsValid(showcase) then showcase:Close() end
    local W = math.min(ScrW() - libNyx.UI.Scale(80), 1200)
    local H = math.min(ScrH() - libNyx.UI.Scale(80), 780)
    showcase = libNyx.UI.CreateFrame({w = W, h = H, title = "Демонстрация libNyx UI"})

    local pages = vgui.Create("DPanel", showcase)
    pages:Dock(FILL)
    pages:DockMargin(Style.padding, Style.padding, Style.padding, Style.padding)
    pages.Paint = nil

    local page1, page2
    local function showPage(which)
        if IsValid(page1) then page1:SetVisible(which == 1) end
        if IsValid(page2) then page2:SetVisible(which == 2) end
    end

    local nav = Components.CreateTabs(showcase, {
        items = {
            {id="p1", label="демка 1", icon=Material("icon16/page_white.png","noclamp smooth")},
            {id="p2", label="демка 2", icon=Material("icon16/page_white_text.png","noclamp smooth")},
        },
        default = "p1",
        onChange = function(id) showPage(id == "p1" and 1 or 2) end
    })
    nav:Dock(TOP)
    nav:SetTall(libNyx.UI.Scale(52))
    nav:DockMargin(Style.headerIndentX, Style.headerIndentY + libNyx.UI.Scale(8), Style.headerIndentX, libNyx.UI.Scale(6))


    page1 = vgui.Create("DPanel", pages)
    page1:Dock(FILL)
    page1.Paint = nil

    do

        local left = vgui.Create("DPanel", page1)
        left:Dock(LEFT)
        left:SetWide(math.floor(W * 0.40))
        left.Paint = function(s,w,h)
            libNyx.UI.Draw.Panel(0,0,w,h,{radius=Style.radius, color=Style.panelColor, glass=true})
        end
        left:DockMargin(0, 0, Style.padding, 0)

        local leftStack = vgui.Create("DPanel", left)
        leftStack:Dock(FILL)
        leftStack:DockPadding(Style.padding, Style.padding, Style.padding, Style.padding)
        leftStack.Paint = nil

        local checksRow = vgui.Create("DPanel", leftStack)
        checksRow:Dock(TOP)
        checksRow:SetTall(libNyx.UI.Scale(32))
        checksRow:DockMargin(0, 0, 0, libNyx.UI.Scale(16))
        checksRow.Paint = nil

        local function addChk(var, text, startOn)
            local c = Components.CreateCheckbox(checksRow, {
                variant = var,
                label   = text,
                checked = startOn,
                tint    = Style.accentColor,
                onChange = function(v)
                    chat.AddText(Color(0,255,0), "[libNyx] ", Color(255,255,0), text, Color(200,200,200), " = ", v and "ON" or "OFF")
                end
            })
            c:Dock(LEFT)
            c:DockMargin(0, 0, libNyx.UI.Scale(16), 0)
            return c
        end

        addChk("switch", "Switch", true)
        addChk("knob",   "Knob",   true)
        addChk("radio",  "Radio",  true)

        -- buttons
        local b1 = Components.CreateButton(leftStack, "Основная",   {variant="primary",   align="left"})
        b1:Dock(TOP) b1:DockMargin(0, 0, 0, libNyx.UI.Scale(10))

        local b2 = Components.CreateButton(leftStack, "Мягкая",     {variant="soft",      align="left"})
        b2:Dock(TOP) b2:DockMargin(0, 0, 0, libNyx.UI.Scale(10))

        local b3 = Components.CreateButton(leftStack, "Прозрачная", {variant="ghost",     align="left"})
        b3:Dock(TOP) b3:DockMargin(0, 0, 0, libNyx.UI.Scale(10))

        local b4 = Components.CreateButton(leftStack, "Градиентная",{variant="gradient",  align="left", tint = PalettePick("btn")})
        b4:Dock(TOP) b4:DockMargin(0, 0, 0, libNyx.UI.Scale(16))

        local b5 = Components.CreateButton(leftStack, "солид",      {variant="primary_center"})
        b5:Dock(TOP) b5:DockMargin(0, 0, 0, libNyx.UI.Scale(10))

        local b6 = Components.CreateButton(leftStack, "Центр-гр",   {variant="center_duo", tint = Color(97,17,191), centerTint = Color(136,49,238)})
        b6:Dock(TOP)
        b6:DockMargin(0, 0, 0, libNyx.UI.Scale(16))

        local sld = Components.CreateSlider(leftStack, {min=1, max=100, value=42, decimals=0, tint=Style.accentColor})
        sld:Dock(TOP) sld:DockMargin(0, 0, 0, libNyx.UI.Scale(16))
        sld:SetTall(libNyx.UI.Scale(30))

        local dd = Components.CreateDropdown(leftStack, {
            placeholder = "Выберите категорию",
            choices = {"Недвижимость", "Бизнес", "Промо", "VIP"},
            onSelect = function(val) chat.AddText(Color(0,255,0), "[libNyx] Вы выбрали: ", Color(255,255,0), val) end,
            tint = PalettePick("dropdown")
        })
        dd:Dock(TOP) dd:DockMargin(0, 0, 0, libNyx.UI.Scale(8))
        dd:SetTall(libNyx.UI.Scale(36))

        -- bullets
        local feats = {"The libNyx 1.0","Nyx Team топ","бээ-бээ барашек"}
        for _, t in ipairs(feats) do
            local row = vgui.Create("DPanel", leftStack)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, libNyx.UI.Scale(8))
            row:SetTall(libNyx.UI.Scale(30))
            row.Paint = function(s,w,h)
                libNyx.UI.Draw.Panel(0,0,w,h,{radius=libNyx.UI.Scale(8), color=Style.cardColor, glass=true})
                draw.SimpleText("•  "..t, libNyx.UI.Font(libNyx.UI.Scale(18)), libNyx.UI.Scale(8), h/2, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end

        -- right pane
        local right = vgui.Create("DPanel", page1)
        right:Dock(FILL)
        right.Paint = function(s,w,h)
            libNyx.UI.Draw.Panel(0,0,w,h,{radius=Style.radius, color=Style.panelColor, glass=true})
        end

        -- bottom boxes strip
        local strip = vgui.Create("DPanel", right)
        strip:Dock(BOTTOM)
        strip:SetTall(libNyx.UI.Scale(220))
        strip:DockMargin(Style.padding, 0, Style.padding, Style.padding)
        strip.Paint = nil

        local bx1 = Components.CreateVBox(strip, {variant = "center_gradient", title = "Бокс1", icon = Material("icon16/heart.png"), tint = Color(140,120,255)})
        bx1:Dock(LEFT); bx1:DockMargin(0,0,Style.padding,0)

        local bx2 = Components.CreateVBox(strip, {variant = "sunburst", title = "Бокс2", icon = Material("icon16/star.png"), tint = Color(255,180,90)})
        bx2:Dock(LEFT); bx2:DockMargin(0,0,Style.padding,0)

        local bx3 = Components.CreateVBox(strip, {variant = "model", title = "Бокс3", model = "models/props_c17/oildrum001.mdl", tint = Color(120,200,255)})
        bx3:Dock(LEFT); bx3:DockMargin(0,0,Style.padding,0)

        local bx4 = Components.CreateVBox(strip, {variant = "vertical_gradient", title = "Бокс4", icon = Material("icon16/flag_yellow.png"), tint = Color(120,180,255)})
        bx4:Dock(LEFT)

        -- list
        local list = Components.CreateList(right, {rowHeight = Style.rowHeight, vbarWidth = libNyx.UI.Scale(12)})
        list:Dock(FILL)
        list:DockMargin(Style.padding, Style.padding, Style.padding, Style.padding)

        local iconShop = Material("icon16/cart.png")
        local iconHome = Material("icon16/house.png")

        list:AddRow({
            title = "Строка с иконкой и метками",
            icon  = iconShop,
            labels = {
                {text="Премиум",       color=Color(255,215,0)},
                {text="Новинка",       color=Color(90,160,255)},
                {text="Рекомендуем",   color=Color(120,220,160)},
            },
            rightText = "12 000 kr",
            onClick   = function() chat.AddText(Color(0,255,0),"[libNyx] Нажата строка 1") end
        })

        list:AddRow({
            title = "Строка без иконки",
            labels = { {text="Скоро", color=Color(170,120,255)} },
            rightText = "Бесплатно",
            gradient  = false,
            onClick   = function() chat.AddText(Color(0,255,0),"[libNyx] Нажата строка 2 (plain)") end
        })

        list:AddRow({
            title = "Строка с множеством меток",
            icon  = iconHome,
            labels = {
                {text="Скидка",        color=Color(120,220,160)},
                {text="Ограничено",    color=Color(255,125,155)},
                {text="-15%",          color=Color(255,200,120)},
                {text="Сегодня",       color=Color(120,200,255)},
                {text="Дополнительно", color=Color(90,160,255)},
            },
            rightText = "8 500 kr",
        })


        local inv = vgui.Create("DPanel", right)
        inv:Dock(TOP)
        inv:SetTall(libNyx.UI.Scale(110))
        inv:DockMargin(Style.padding, Style.padding, Style.padding, 0)
        inv.Paint = nil

        local invCellA = Components.CreateInteractiveCell(inv, {size=libNyx.UI.Scale(88), tint=Color(140,120,255)})
        invCellA:Dock(LEFT)
        invCellA:DockMargin(0,0,Style.padding,0)

        local invCellB = Components.CreateInteractiveCell(inv, {size=libNyx.UI.Scale(88), tint=Color(120,200,255)})
        invCellB:Dock(LEFT)

        invCellA:SetItemIcon(
            Material("materials_umbrellyx/moreicons/doughnut-1.png", "noclamp smooth"),
            libNyx.UI.Scale(40),
            {
                title = "Пончик «Глазурь»",
                desc  = "Сладкий круглый десерт с сахарной глазурью. Даёт +25 к настроению и немного утоляет голод.",
                tags  = {
                    {text="Еда",      color=Color(255,180,90)},
                    {text="Сладкое",  color=Color(255,125,155)},
                    {text="Эпик",     color=Color(170,120,255)}
                }
            }
        )

        -- (optional) leave empty to demo drag-drop target
        -- if u want a second example, uncomment:
        -- invCellB:SetItemIcon(Material("icon16/box.png","noclamp smooth"), libNyx.UI.Scale(36), {
        --     title = "Пустая коробка",
        --     desc  = "Прочная тара для переноски мелких предметов.",
        --     tags  = {"Контейнер", {text="Обычный", color=Color(120,200,255)}}
        -- })

    end

    page2 = vgui.Create("DPanel", pages)
    page2:Dock(FILL)
    page2:SetVisible(false)
    page2.Paint = function(s,w,h)
        libNyx.UI.Draw.Panel(0,0,w,h,{radius=Style.radius, color=Style.panelColor, glass=true})
    end

    do
        local subnav = Components.CreateTabs(page2, {
            items = {
                { id = "stylish",  label = "Стильно",        icon = Material("icon16/page_white_text.png","noclamp smooth") },
                { id = "pretty",   label = "Красиво",        icon = Material("icon16/newspaper.png","noclamp smooth") },
                { id = "modern",   label = "Современно",     icon = Material("icon16/fire.png","noclamp smooth") },
                { id = "nyxnyx",   label = "никс-никс-никс", icon = Material("icon16/heart.png","noclamp smooth") },
                { id = "woohoo",   label = "Делаем вуху?",   icon = Material("icon16/user.png","noclamp smooth") },
                { id = "r34",      label = "r34",            icon = Material("icon16/star.png","noclamp smooth") },
            },
            default  = "pretty",
            onChange = function()
                page2:InvalidateLayout(true)
            end
        })
        subnav:Dock(TOP)
        subnav:SetTall(libNyx.UI.Scale(52))
        subnav:DockMargin(Style.padding, Style.padding, Style.padding, libNyx.UI.Scale(12))

        local content = vgui.Create("DPanel", page2)
        content:Dock(FILL)
        content:DockMargin(Style.padding, 0, Style.padding, Style.padding)
        content.Paint = function(s,w,h)
            libNyx.UI.Draw.Panel(0,0,w,h,{radius=Style.radius, color=Color(12,14,20,110), glass=true})
        end

        local toolbar = vgui.Create("DPanel", page2)
        toolbar:Dock(TOP)
        toolbar:SetTall(libNyx.UI.Scale(48))
        toolbar:DockMargin(Style.padding, Style.padding, Style.padding, 0)
        toolbar.Paint = nil

        local flow = vgui.Create("DIconLayout", content)
        flow:Dock(FILL)
        flow:DockMargin(Style.padding, Style.padding, Style.padding, Style.padding)
        flow:SetSpaceX(Style.padding)
        flow:SetSpaceY(Style.padding)

        local function cardWidth()
            local w = content:GetWide()
            return math.max(libNyx.UI.Scale(220), math.floor((w - Style.padding*3) / 2))
        end

        local data = {
            {variant="vibrant", title="Nyx Team", desc="Делаем не только красиво.", from=Color(129,82,255), to=Color(40,192,255), icon="werewolf/0x00000000!0x8aaf8d0ab771a3b9.0x00b2d882.png"},
            {variant="vibrant", title="Nyx Team", desc="Делаем не только красиво.", from=Color(255,94,176), to=Color(255,142,220), icon="werewolf/0x00000000!0xfce5734b8472e83f.0x00b2d882.png"},
            {variant="glass",   title="Nyx Team", desc="Делаем не только красиво.", from=Color(58,160,255), to=Color(40,120,255), icon="werewolf/0x00000000!0xfc708fa9e974b2cb.0x00b2d882.png"},
            {variant="glass",   title="Nyx Team", desc="Делаем не только красиво.", from=Color(72,210,150), to=Color(28,190,140), icon="werewolf/0x00000000!0xf4e5b382cf4f862d.0x00b2d882.png"},
        }

        local function clearFlow()
            for _, ch in ipairs(flow:GetChildren()) do if IsValid(ch) then ch:Remove() end end
        end

        local function renderCards(query)
            query = string.Trim(string.lower(query or ""))
            clearFlow()
            for _, t in ipairs(data) do
                local hay = string.lower((t.title or "") .. " " .. (t.desc or ""))
                if query == "" or string.find(hay, query, 1, true) then
                    local c = Components.CreateCategoryCard(flow, t)
                    c:SetSize(cardWidth(), libNyx.UI.Scale(120))
                end
            end
            flow:InvalidateLayout(true)
        end

        local search = Components.CreateSearchBox(toolbar, {
            placeholder = "Поиск…",
            tint = Style.accentColor,
            onChange = function(q) renderCards(q) end,
            onSubmit = function(q) renderCards(q) end,
            onClear  = function() renderCards("") end
        })
        search:Dock(FILL)

        content.OnSizeChanged = function()
            local cw = cardWidth()
            for _, ch in ipairs(flow:GetChildren()) do
                ch:SetSize(cw, libNyx.UI.Scale(120))
            end
            flow:InvalidateLayout(true)
        end

        renderCards("")
    end

    showPage(1)
end

concommand.Add("libnyx_ui_showcase", function() -- comm to open
    libNyx.UI.OpenShowcase()
end)



















































-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
