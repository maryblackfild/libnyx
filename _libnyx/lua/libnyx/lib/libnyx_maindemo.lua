
if SERVER then
    AddCSLuaFile()
    return
end

if not libNyx or not libNyx.ui or not libNyx.ui.components then return end

local style      = libNyx.ui.style
local components = libNyx.ui.components

local gradientPalette = {
    Color( 90,160,255),
    Color(255,125,155),
    Color(120,220,160),
    Color(255,200,120),
    Color(170,120,255),
    Color(120,200,255),
}
local function palettePick(key)
    key = tostring(key or "")
    local sum = 0
    for i = 1, #key do sum = sum + key:byte(i) end
    local idx = (sum % #gradientPalette) + 1
    return gradientPalette[idx]
end

local showcase
function libNyx.ui.openShowcase()
    if IsValid(showcase) then showcase:Close() end
    local windowWidth = math.min(ScrW() - libNyx.ui.scale(80), 1200)
    local windowHeight = math.min(ScrH() - libNyx.ui.scale(80), 780)
    showcase = libNyx.ui.createFrame({w = windowWidth, h = windowHeight, title = "Демонстрация libNyx UI", blur = true})

    local pages = vgui.Create("DPanel", showcase)
    pages:Dock(FILL)
    pages:DockMargin(style.padding, style.padding, style.padding, style.padding)
    pages.Paint = nil

    local page1, page2
    local function showPage(which)
        if IsValid(page1) then page1:SetVisible(which == 1) end
        if IsValid(page2) then page2:SetVisible(which == 2) end
    end

    local nav = components.createTabs(showcase, {
        items = {
            {id="p1", label="демка 1", icon=Material("icon16/page_white.png","noclamp smooth")},
            {id="p2", label="демка 2", icon=Material("icon16/page_white_text.png","noclamp smooth")},
        },
        default = "p1",
        onChange = function(id) showPage(id == "p1" and 1 or 2) end
    })
    nav:Dock(TOP)
    nav:SetTall(libNyx.ui.scale(52))
    nav:DockMargin(style.headerIndentX, style.headerIndentY + libNyx.ui.scale(8), style.headerIndentX, libNyx.ui.scale(6))


    page1 = vgui.Create("DPanel", pages)
    page1:Dock(FILL)
    page1.Paint = nil

    do

        local left = vgui.Create("DPanel", page1)
        left:Dock(LEFT)
        left:SetWide(math.floor(windowWidth * 0.40))
        left.Paint = nil
        left:DockMargin(0, 0, style.padding, 0)

        local leftStack = vgui.Create("DPanel", left)
        leftStack:Dock(FILL)
        leftStack:DockPadding(style.padding, style.padding, style.padding, style.padding)
        leftStack.Paint = nil

        local checksRow = vgui.Create("DPanel", leftStack)
        checksRow:Dock(TOP)
        checksRow:SetTall(libNyx.ui.scale(32))
        checksRow:DockMargin(0, 0, 0, libNyx.ui.scale(16))
        checksRow.Paint = nil

        local switch = components.createCheckbox(checksRow, {
            label = "Switch",
            checked = true,
            tint = style.accentColor,
            onChange = function(value)
                chat.AddText(
                    Color(0,255,0),
                    "[libNyx] ",
                    Color(255,255,0),
                    "Switch",
                    Color(200,200,200),
                    " = ",
                    value and "ON" or "OFF"
                )
            end
        })
        switch:Dock(LEFT)

        local b1 = components.createButton(leftStack, "Основная",   {variant="primary",   align="left"})
        b1:Dock(TOP) b1:DockMargin(0, 0, 0, libNyx.ui.scale(10))

        local b2 = components.createButton(leftStack, "Мягкая",     {variant="soft",      align="left"})
        b2:Dock(TOP) b2:DockMargin(0, 0, 0, libNyx.ui.scale(10))

        local b3 = components.createButton(leftStack, "Прозрачная", {variant="ghost",     align="left"})
        b3:Dock(TOP) b3:DockMargin(0, 0, 0, libNyx.ui.scale(10))

        local b4 = components.createButton(leftStack, "Градиентная",{variant="gradient",  align="left", tint = palettePick("btn")})
        b4:Dock(TOP) b4:DockMargin(0, 0, 0, libNyx.ui.scale(16))

        local b5 = components.createButton(leftStack, "солид",      {variant="primaryCenter"})
        b5:Dock(TOP) b5:DockMargin(0, 0, 0, libNyx.ui.scale(10))

        local b6 = components.createButton(leftStack, "Центр-гр",   {variant="centerDuo", tint = Color(97,17,191), centerTint = Color(136,49,238)})
        b6:Dock(TOP)
        b6:DockMargin(0, 0, 0, libNyx.ui.scale(16))

        local sld = components.createSlider(leftStack, {min=1, max=100, value=42, decimals=0, tint=style.accentColor})
        sld:Dock(TOP) sld:DockMargin(0, 0, 0, libNyx.ui.scale(16))
        sld:SetTall(libNyx.ui.scale(30))

        local dd = components.createDropdown(leftStack, {
            placeholder = "Выберите категорию",
            choices = {"Недвижимость", "Бизнес", "Промо", "VIP"},
            onSelect = function(val) chat.AddText(Color(0,255,0), "[libNyx] Вы выбрали: ", Color(255,255,0), val) end,
            tint = palettePick("dropdown")
        })
        dd:Dock(TOP) dd:DockMargin(0, 0, 0, libNyx.ui.scale(8))
        dd:SetTall(libNyx.ui.scale(36))

        local feats = {"The libNyx 1.0","Nyx Team топ","бээ-бээ барашек"}
        for _, t in ipairs(feats) do
            local row = vgui.Create("DPanel", leftStack)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, libNyx.ui.scale(8))
            row:SetTall(libNyx.ui.scale(30))
            row.Paint = function(s,w,h)
                libNyx.ui.draw.panel(0,0,w,h,{radius=libNyx.ui.scale(8), color=style.cardColor})
                draw.SimpleText("•  "..t, libNyx.ui.font(libNyx.ui.scale(18)), libNyx.ui.scale(8), h/2, style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end

        local right = vgui.Create("DPanel", page1)
        right:Dock(FILL)
        right.Paint = nil

        local strip = vgui.Create("DPanel", right)
        strip:Dock(BOTTOM)
        strip:SetTall(libNyx.ui.scale(220))
        strip:DockMargin(style.padding, 0, style.padding, style.padding)
        strip.Paint = nil

        local bx1 = components.createVBox(strip, {variant = "centerGradient", title = "Бокс1", icon = Material("icon16/heart.png"), tint = Color(140,120,255)})
        bx1:Dock(LEFT); bx1:DockMargin(0,0,style.padding,0)

        local bx2 = components.createVBox(strip, {variant = "sunburst", title = "Бокс2", icon = Material("icon16/star.png"), tint = Color(255,180,90)})
        bx2:Dock(LEFT); bx2:DockMargin(0,0,style.padding,0)

        local bx3 = components.createVBox(strip, {variant = "model", title = "Бокс3", model = "models/props_c17/oildrum001.mdl", tint = Color(120,200,255)})
        bx3:Dock(LEFT); bx3:DockMargin(0,0,style.padding,0)

        local bx4 = components.createVBox(strip, {variant = "verticalGradient", title = "Бокс4", icon = Material("icon16/flag_yellow.png"), tint = Color(120,180,255)})
        bx4:Dock(LEFT)

        local list = components.createList(right, {rowHeight = style.rowHeight, vbarWidth = libNyx.ui.scale(12)})
        list:Dock(FILL)
        list:DockMargin(style.padding, style.padding, style.padding, style.padding)

        local iconShop = Material("icon16/cart.png")
        local iconHome = Material("icon16/house.png")

        list:addRow({
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

        list:addRow({
            title = "Строка без иконки",
            labels = { {text="Скоро", color=Color(170,120,255)} },
            rightText = "Бесплатно",
            gradient  = false,
            onClick   = function() chat.AddText(Color(0,255,0),"[libNyx] Нажата строка 2 (plain)") end
        })

        list:addRow({
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
        inv:SetTall(libNyx.ui.scale(110))
        inv:DockMargin(style.padding, style.padding, style.padding, 0)
        inv.Paint = nil

        local invCellA = components.createInteractiveCell(inv, {size=libNyx.ui.scale(88), tint=Color(140,120,255)})
        invCellA:Dock(LEFT)
        invCellA:DockMargin(0,0,style.padding,0)

        local invCellB = components.createInteractiveCell(inv, {size=libNyx.ui.scale(88), tint=Color(120,200,255)})
        invCellB:Dock(LEFT)

        invCellA:setItemIcon(
            Material("materials_umbrellyx/moreicons/doughnut-1.png", "noclamp smooth"),
            libNyx.ui.scale(40),
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


    end

    page2 = vgui.Create("DPanel", pages)
    page2:Dock(FILL)
    page2:SetVisible(false)
    page2.Paint = nil

    do
        local subnav = components.createTabs(page2, {
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
        subnav:SetTall(libNyx.ui.scale(46))
        subnav:DockMargin(0, 0, 0, libNyx.ui.scale(6))

        local toolbar = vgui.Create("DPanel", page2)
        toolbar:Dock(TOP)
        toolbar:SetTall(libNyx.ui.scale(38))
        toolbar:DockMargin(0, 0, 0, libNyx.ui.scale(8))
        toolbar.Paint = nil

        local content = vgui.Create("DPanel", page2)
        content:Dock(FILL)
        content.Paint = nil

        local flow = vgui.Create("DIconLayout", content)
        flow:Dock(FILL)
        flow:DockMargin(0, 0, 0, 0)
        flow:SetSpaceX(style.padding)
        flow:SetSpaceY(style.padding)

        local function cardWidth()
            local w = content:GetWide()
            return math.max(libNyx.ui.scale(220), math.floor((w - style.padding) / 2))
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
                    local c = components.createCategoryCard(flow, t)
                    c:SetSize(cardWidth(), libNyx.ui.scale(120))
                end
            end
            flow:InvalidateLayout(true)
        end

        local search = components.createSearchBox(toolbar, {
            placeholder = "Поиск…",
            tint = style.accentColor,
            onChange = function(q) renderCards(q) end,
            onSubmit = function(q) renderCards(q) end,
            onClear  = function() renderCards("") end
        })
        search:Dock(FILL)

        content.OnSizeChanged = function()
            local cw = cardWidth()
            for _, ch in ipairs(flow:GetChildren()) do
                ch:SetSize(cw, libNyx.ui.scale(120))
            end
            flow:InvalidateLayout(true)
        end

        renderCards("")
    end

    showPage(1)
end

concommand.Add("libnyx_ui_showcase", function()
    libNyx.ui.openShowcase()
end)
