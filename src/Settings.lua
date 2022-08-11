-- Settings displays game's menus.
-- Menus display game info and allow user to change preferences stored in global 'PREFS' table.
-- Settings is initiated by user click on 'mug' icon.
-- Main calls 'openMenuPage' function.
-- openMenuPage calls 'getPage' (once) and 'getButtons' (multiple)
-- return values (button and page objects) are stored in global table MENUS
-- objects' draw/onHover/onClick methods are called by 'settingsUpdate' and 'drawSettings' functions
-- user clicks on a button, button's onClick method calls a function to either change a setting, display a value, or call openMenuPage
-- Repeat calls to openMenuPage by onClick methods open nested menu pages by same system as above, with addition of call to 'getBackButton' for a backButton object as of the first nested menu page
-- Active PREFS settings maintained/updated by calls to 'activeSettingsTest' function when user clicks to change pref
-- Active PREFS stored in kSet field (bool) and marked by keyIcon when displayed

--Global variables (plus 'BUTTONS', added lower):
MENUS = {}
FOLDER = {}
SET_BOOK = {}
SUBJECTS = {}
COURIERWL = 14
COURIERWM = 12
COURIERWS = 10

PREFS = {}
PREFS.search = 1
PREFS.size = 250
PREFS.skip = 1
PREFS.speed = 1

COLORS = {}
COLORS.pink = {1,0.2,0.7}
COLORS.lightblue = {0.26,0.75,0.98}
COLORS.red = {1,0,0}
COLORS.blue = {0,0,1}
COLORS.green = {0.68,1,0.18}
COLORS.lightgreen = {0.15,0.6,0.35}
COLORS.lightpurple = {0.80,0,1}
COLORS.lightgray = {0.7,0.7,0.7}
COLORS.lightred ={1,0.5,0.5}
COLORS.darkred = {0.6,0,0}
COLORS.crimson = {214/255,26/255,60/255}
COLORS.darkpurple = {0.21,0,0.25}
COLORS.ivory = {1,1,0.94}

-- Format y-shift for mobile
DRAW_HEIGHT_ADJ = 460

ISDOWN_COUNTER = -10

--Troubleshooting
ONCLICKARRIVED = 0
OPENMUNUPAGEARRIVED = 0
GETPAGEARRIVED = 0
BUTTONONCLICKARRIVED = 0
MOUSE_X = 0
MOUSE_Y = 0
PAGEARRIVED = 0
PAGEOPENARRIVED = 0
BOOKARRIVED = 0
CLOSEBOOKARRIVED = 0
MOUSEPRESSEDARRIVED = 0
CBARRIVED = 0
CBMATCHED = 0
CLOSEFOLDERARRIVED = 0
SUBJECTS = {}
VSUBJARRIVED = 0
SUBJCALLARRIVED = 0
INFO_COUNTER = 0

local settingsPage = love.graphics.newImage('assets/sprites/settingsPage4.png')
local settingsPageFaded = love.graphics.newImage('assets/sprites/sPageFaded.png')

local setPage = love.graphics.newCanvas(DRAW_WIDTH, DRAW_HEIGHT)
love.graphics.setCanvas(setPage) 
    love.graphics.draw(settingsPage,0,-20,0,0.6)
love.graphics.setCanvas()

local setPageFaded = love.graphics.newCanvas(DRAW_WIDTH, DRAW_HEIGHT)
love.graphics.setCanvas(setPageFaded) 
    love.graphics.draw(settingsPageFaded,0,-20,0,0.6)
love.graphics.setCanvas()

--Caller: new page
function openMenuPage (params)
    OPENMUNUPAGEARRIVED = OPENMUNUPAGEARRIVED + 1
    local level = #MENUS + 1 or 1
    local marginR = DRAW_WIDTH*0.4+level*20*DRAW_SCALE
    local marginT = level*10*DRAW_SCALE
    local page = getPage(level, marginR, marginT)
    page:open()
    local buttons = {}
    local num = #params
    --kSet: test if buttons are PREFS display
    local kSet = false
    for i,v in ipairs(params) do
        kSet = activeSettingsTest(v)
        local button = getMenuButton(i,v,num,kSet, level, marginR, marginT)
        button:open()
        table.insert(buttons, button)
    end
    local backButton = {}
    backButton = getBackButton(level, marginR, marginT)
    backButton:open()
    return {
        page = page,
        buttons = buttons,
        backButton = backButton,
    }
end

--backButton constructor
function getBackButton(level, marginR, marginT)
    local text = 'BACK'
    local text_x = marginR + 20
    local text_y = marginT + 10
    local button_x = text_x + 5
    local button_y = text_y + 2
    local width = 50
    local height = 20
    local opacity = 0
    local button_opacity = 0
    local red = 0
    local green = 1
    local blue = 0
    local period = 0.2

    return {
        text = text,
        text_x = text_x,
        text_y = text_y,
        button_x = button_x,
        button_y = button_y,
        width = width,
        height = height,
        opacity = opacity,
        button_opacity = button_opacity,
        red = red,
        green = green,
        blue = blue,
        period = period,
        level = level,

        open = function(self)
            Timer.tween(1, self, {opacity = 1})
        end,

        close = function(self, period, delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period, self, {opacity = 0})
            end)
            return period + delay
        end,

        onHover = function (self,dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if my >= self.button_y and my <= self.button_y + self.height then
                    self.button_opacity = 0.3
                else
                    self.button_opacity = 0
                end
            end
        end,

        onClick = function(self,mouse_x,mouse_y)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    pageBack()
                end
            end 
        end,

        onEnter = function()
            pageBack()
        end,

        draw = function (self)
            love.graphics.setColor(self.red,self.green,self.blue,self.button_opacity)
            love.graphics.rectangle('fill',self.button_x,self.button_y,self.width,self.height)
            love.graphics.setFont(FONT.courier)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.print(self.text,self.text_x,self.text_y)
        end
    }
end

function pageBack()
    if #MENUS == 1 then
        hideSettings()
    else
        local totalDelay = 0.01
        local pageDelay = MENUS[#MENUS].page:close()
        local backDelay = MENUS[#MENUS].backButton:close()
        local buttonsDelay = 0.01
        local buttonDelay = 0.01
        if MENUS[#MENUS].buttons then 
            for i,v in ipairs(MENUS[#MENUS].buttons) do
                buttonDelay = v:close() or 0.01
                buttonsDelay = buttonsDelay + buttonDelay
            end
        end
        totalDelay = pageDelay or 0.01
        if backDelay > pageDelay then
            totalDelay = backDelay
        end
        if buttonsDelay > totalDelay then
            totalDelay = buttonsDelay
        end
        Timer.after(totalDelay, function() table.remove(MENUS, #MENUS) end)
    end
end

function openFolder()
    local folder = getFolder()
    local delay = folder:open()
    local folderEntry = {}
    local entries = {}
    local num = 1
    local headers = {}
    local closeButton = {}
    TWICON:toSettings()
    headers = getHeaders()
    local count = #USERDATA
    for i,v in ipairs(USERDATA) do
        folderEntry = getFolderEntries(i,v,num,count)
        num = num + folderEntry.entries
        table.insert(entries, folderEntry)
    end
    Timer.after(delay, function()
        for _,v in ipairs(entries) do
            v:open()
        end
        headers:open()
    end)
    FOLDER = {
        folder = folder,
        entries = entries,
        headers = headers,
        modals = {
        getButton({ICONS.upArrow},scrollUp,'params',DRAW_WIDTH*0.1,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.3,DRAW_HEIGHT*0.04,COLORS.pink,{20},{FONT.roboto},4,{},{entries}),
        getButton({ICONS.check},selectThis,'params',DRAW_WIDTH*0.45,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.1,DRAW_HEIGHT*0.04,COLORS.green,{20},{FONT.roboto},5,{},{entries}),
        getButton({ICONS.downArrow},scrollDown,'params',DRAW_WIDTH*0.6,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.3,DRAW_HEIGHT*0.04,COLORS.lightpurple,{20},{FONT.roboto},6,{},{entries}),
        getInfoButton(DRAW_WIDTH*0.95,DRAW_HEIGHT*0.965,24,COLORS.crimson,{},entries),
        getCloseButton(closeFolder,{},entries)
        }
    }
    for _,v in ipairs(FOLDER.modals) do 
        v.modals = FOLDER.modals
    end
    Timer.after(delay, function()
        for _,v in ipairs(FOLDER.modals) do
            v:open()
        end
    end)
end

--button constructor
function getMenuButton(index, params, num, kSet, level, marginR, marginT)
    local text_x = marginR + 100
    local step_y = (DRAW_HEIGHT - marginT + 80*DRAW_SCALE)/(num+1)
    local text_y = marginT + 80*DRAW_SCALE + step_y*(index-1)
    local text = params[1] or "No text"
    local func = params[2]
    local func_params = params[3] or nil
    local opacity = 0
    local button_x = text_x - 5
    local button_y = text_y - 2
    local width = 800 - button_x
    local lines = 1
    local _,lineBoost = string.gsub(text,'\n', '')
    lines = lines + lineBoost
    local height = lines*24 + 4
    local button_opacity = 0
    local red = 0
    local green = 1
    local blue = 0
    local inverseIndex = math.abs(index-1-num)
    local kSet = kSet
    local cursor = false
    if index == 1 then
        cursor = true
    end
    local top = marginT + 80*DRAW_SCALE
    local period = 0.1

    return {
        index = index,
        width = width,
        height = height,
        func = func,
        func_params = func_params,
        text = text,
        button_x = button_x,
        button_y = button_y,
        text_x = text_x,
        text_y = text_y,
        opacity = opacity,
        red = red,
        green = green,
        blue = blue,
        button_opacity = button_opacity,
        kSet = kSet,
        inverseIndex = inverseIndex,
        level = level,
        cursor = cursor,
        top = top,
        period = period,

        open = function(self)
            Timer.after((self.index-1)*0.2, function()
                Timer.tween(0.1, self, {opacity = 1})
                if self.cursor == true then
                    Timer.tween(0.1, self, {button_opacity = 0.3})
                end
            end)
        end,

        close = function(self,period,delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period, self, {opacity = 0})
            end)
            return period + delay
        end,

        onHover = function(self, dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if my >= self.button_y and my <= self.button_y + self.height then
                    self:getCursor(true)
                else
                    self:getCursor()
                end
            end
        end,
        
        onClick = function (self,mouse_x,mouse_y)
            BUTTONONCLICKARRIVED = BUTTONONCLICKARRIVED + 1
            MOUSE_X = mouse_x
            MOUSE_Y = mouse_y
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    ONCLICKARRIVED = ONCLICKARRIVED + 1
                    if self.func == openMenuPage or self.func == openAboutPage then
                        table.insert(MENUS, self.func(self.func_params))
                    else
                        self.func(self.func_params)
                    end
                end
            end 
        end,

        getCursor = function(self,bool)
            if bool then
                self.cursor = true
                self:showButton(bool)
            else
                self.cursor = false
                self:showButton()
            end
        end,

        showButton = function(self,bool)
            if bool then
                self.button_opacity = 0.3
            elseif self.cursor == false then
                self.button_opacity = 0
            end
        end,

        onEnter = function(self)
            if self.func == openMenuPage or self.func == openAboutPage then
                table.insert(MENUS, self.func(self.func_params))
            elseif self.func == openFolder then
                self.func(self.func_params)        
            else
                self.func(self.func_params)
            end
        end,

        draw = function(self)
            love.graphics.setColor(self.red,self.green,self.blue,self.button_opacity)
            love.graphics.rectangle('fill',self.button_x,self.button_y,self.width,self.height)
            love.graphics.setFont(FONT.courier)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.print(self.text,self.text_x,self.text_y)
            if self.kSet == true then
                love.graphics.setColor (1,1,1,self.opacity)
                love.graphics.draw(ICONS.key, self.text_x - 75, self.text_y - 25, nil, 1.5)
            end
            love.graphics.setColor(1,1,1)
        end
    }
end

--page constructor
function getPage(level, marginR, marginT)
    GETPAGEARRIVED = GETPAGEARRIVED + 1
    local originX = DRAW_WIDTH
    local y = marginT
    local targetX = marginR
    local x = originX
    local period = 0.2

    return {
        originX = originX,
        x = x,
        y = y,
        targetX = targetX,
        level = level,
        period = period,

        open = function(self)
            Timer.tween(0.2, self, {x = self.targetX})
        end,

        close = function(self, period, delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period, self, {x = self.originX})
            end)
            return period + delay
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(setPage, self.x, self.y)
        end
    }
end

function buttonRefresh()
    for _,v in ipairs(MENUS[#MENUS].buttons) do
        local kSt = activeSettingsTest(v)
        v.kSet = kSt
    end
end

--Value/display (terminal) menu functions
function searchTarget(num) 
    PREFS.search = num    
    buttonRefresh() 
end

function sizePassage(num)
    PREFS.size = num  
    buttonRefresh()         
end

function skipAhead(num)
    PREFS.skip = num
    buttonRefresh() 
end

function speedBoost(num)
    PREFS.speed = num
    buttonRefresh() 
end

function formatAboutText(txt,line_px,char_px)
    local cursor = 0
    local char_px = char_px or 12
    local lineCursor = 0
    local tempTextL = ''
    local tempTextR = ''
    local lines = {}
    local maxChar = math.floor(line_px/char_px)
    local textCopy = txt
    for i in string.gmatch(textCopy, "%S+") do
        if lineCursor + #i + 1 > maxChar + 1 then
            local _,z = string.find(string.sub(txt, lineCursor,maxChar), '%-')
            if z then
                tempTextL = string.sub(txt, 1, lineCursor + z - 1)
            else
                tempTextL = string.sub(txt, 1, lineCursor)
            end
            table.insert(lines,tempTextL)
            if txt then
                if z then
                    tempTextR = string.sub(txt, lineCursor + z)
                else
                    tempTextR = string.sub(txt, lineCursor + 1)
                end
            end
            txt = ''
            txt = tempTextR
            if z then
                cursor = cursor + #i + 2 - z + 1
                lineCursor = #i + 1 - z + 1
            else
                cursor = cursor + #i + 2
                lineCursor = #i + 1
            end
        else
            cursor = cursor + #i + 1
            lineCursor = lineCursor + #i + 1
        end
    end
    if txt ~= '' then
        table.insert(lines,txt)
    end
    return lines, lineCursor*char_px
end

function moreAbout()
    local level = #MENUS + 1 or 1
    local marginR = DRAW_WIDTH*0.4+level*20*DRAW_SCALE
    local marginT = level*10*DRAW_SCALE
    local page = getPage(level, marginR, marginT)
    page:open()
    local backButton = {}
    backButton = getBackButton(level, marginR, marginT)
    backButton:open()
    local text = 'Books are selected at random based on "Search criteria." Hit page back ([u]) twice (or maybe 3 times). Then select "Search criteria" to view and change. It is is the only user input.\n\n\nThe default "Search criteria" picks from books that had more than 5000 downloads/month as of early 2022.'
    local opacity = {opacity = 0}
    Timer.after(0.2,function()
        Timer.tween(0.1,opacity,{opacity = 1})
    end)
    local buttons = {}

    return {
        page = page,
        backButton = backButton,
        opacity = opacity,
        marginR = marginR,
        marginT = marginT,
        text = text,
        buttons = buttons,
        footnote = footnote,

        draw = function(self)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(self.text,FONT.courierM,self.marginR + 100,self.marginT + 120,800 - self.marginR - 130,'left')
        end
    }
end

function getAboutButton(txt,text_x,text_y,char_px,height,func,hotkey)
    local opacity = 0
    local button_x = text_x - 5
    local button_y = text_y - 2
    local width = #txt*char_px + 10
    local buttonOpacity = 0
    local red = 0
    local green = 1
    local blue = 0
    local period = 0.1
    local counter = 0
    local cursor = true
    
    return {
        width = width,
        height = height,
        txt = txt,
        button_x = button_x,
        button_y = button_y,
        text_x = text_x,
        text_y = text_y,
        opacity = opacity,
        red = red,
        green = green,
        blue = blue,
        buttonOpacity = buttonOpacity,
        counter = counter,
        period = period,
        cursor = cursor,
        func = func,
        hotkey = hotkey,

        open = function(self)
            Timer.after(0.2, function()
                Timer.tween(0.1, self, {opacity = 1})
            end)
        end,

        close = function(self,period,delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period, self, {opacity = 0})
            end)
            return period + delay
        end,

        onHover = function(self, dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if my >= self.button_y and my <= self.button_y + self.height then
                    self:showButton()
                else
                    self:hideButton()
                end
            else
                self:hideButton()
            end
        end,

        showButton = function(self)
            self.buttonOpacity = 0.3
        end,

        hideButton = function(self)
            self.buttonOpacity = 0
        end,
        
        onClick = function (self,mouse_x,mouse_y)
            BUTTONONCLICKARRIVED = BUTTONONCLICKARRIVED + 1
            MOUSE_X = mouse_x
            MOUSE_Y = mouse_y
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    ONCLICKARRIVED = ONCLICKARRIVED + 1
                    if self.func == moreAbout then
                        table.insert(MENUS, moreAbout())
                    else
                        self.func()
                    end
                end
            end 
        end,

        mCatcher = function(self,key)
            if key == 'm' then
                table.insert(MENUS, moreAbout())
            end
        end,

        onEnter = function(self,key)
            if key == 'k' then
                self.func()
            end
        end,

        draw = function(self)
            love.graphics.setColor(self.red,self.green,self.blue,self.buttonOpacity)
            love.graphics.rectangle('fill',self.button_x,self.button_y,self.width,self.height)
            love.graphics.setFont(FONT.courier)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.print(self.txt,self.text_x,self.text_y)
            love.graphics.setColor(1,1,1)
        end
    }
end

function gotoGutenberg()
    love.system.openURL("http://gutenberg.org/")
end

function openAboutPage ()
    local level = #MENUS + 1 or 1
    local marginR = DRAW_WIDTH*0.4+level*20*DRAW_SCALE
    local marginT = level*10*DRAW_SCALE
    local page = getPage(level, marginR, marginT)
    page:open()
    local backButton = {}
    backButton = getBackButton(level, marginR, marginT)
    backButton:open()
    local opacity = {opacity = 0}
    local char_px = 14
    local line_height = 28
    local line_px = 800 - marginR - 120
    local page_height = 600 - marginT - 30
    Timer.after(0.2,function()
        Timer.tween(0.1,opacity,{opacity = 1})
    end)
    local top_txt = "Project Gutenberg is a library of 60k+ free eBooks. Founded in 1971. Built by volunteers. Formats for Kindle, EPUB, HTML & Plain text. See gutenberg.org."
    local top_lines,top_lastPx_x = formatAboutText(top_txt,line_px,char_px)
    local bot_txt = "NotQuiteThere is by badwriter. It is built with LOVE 2D. No affiliation with Project Gutenberg."
    local bot_lines,bot_lastPx_x = formatAboutText(bot_txt,line_px,char_px)
    local max_lines = math.floor(page_height/line_height)
    local buffer = math.floor(((max_lines - (#top_lines+#bot_lines))/3)*line_height)
    local top = {
        lines = top_lines,
        x = marginR + 100,
        y = marginT + buffer + 30
    }
    local topButton = {
        text = "(link [k])",
        x = top_lastPx_x  + marginR + 100,
        y = top.y + (#top.lines-1)*line_height
    }

    local bot = {
        lines = bot_lines,
        x = marginR + 100,
        y = top.y + (#top.lines-1)*line_height + buffer
    }
    local button = {
        text = "(more [m])",
        x = bot_lastPx_x + marginR + 100,
        y = bot.y + (#bot.lines-1)*line_height
    }
    if button.x + (#button.text)*char_px > 780 then
        button.y = button.y + line_height 
        button.x = marginR + 100
    end
    if topButton.x + (#button.text)*char_px > 780 then
        topButton.y = topButton.y + line_height 
        topButton.x = marginR + 100
        top.y = top.y - line_height/2
        topButton.y = topButton.y - line_height/2
        bot.y = bot.y + line_height/2
        button.y = button.y + line_height/2
    end
    local buttons = {}
    table.insert(buttons, getAboutButton(topButton.text,topButton.x,topButton.y,char_px,line_height,gotoGutenberg,'k'))
    table.insert(buttons, getAboutButton(button.text,button.x,button.y,char_px,line_height,moreAbout,'m'))
    buttons[1]:open()
    buttons[2]:open()

    return{
        page = page,
        backButton = backButton,
        opacity = opacity,
        lines = lines,
        buttons = buttons,
        marginR = marginR,
        marginT = marginT,
        line_height = line_height,
        bot = bot,
        top = top,

        draw = function(self)
            love.graphics.setColor(0,0,0,self.opacity[1])
            love.graphics.setFont(FONT.courier)
            for i,v in ipairs(self.top.lines) do
                love.graphics.print(v,self.top.x, self.top.y + (i-1)*self.line_height)
            end
            love.graphics.setColor(0,0,0,self.opacity[1])
            for i,v in ipairs(self.bot.lines) do
                love.graphics.print(v,self.bot.x, self.bot.y + (i-1)*self.line_height)
            end
        end

    }
end

--Table: buttons (global variable)
BUTTONS = {
    {"Search criteria", openMenuPage, {
        {"Book popularity (dls/mo.)", openMenuPage, {
            {"+5000 dls/mo.", searchTarget, 1},
            {"+1000 dls/mo.", searchTarget, 2},
            {"+100 dls/mo.", searchTarget, 3},
            {"-5 dls/mo.", searchTarget, 4},
            }
        },
        {"Uploaded recently", openMenuPage, {
            {"uploaded 2022", searchTarget, 5},
            {"uploaded 2021", searchTarget, 6}
            }
        }
        }
    },
    {"My folder", openFolder},
    {"Game speed", openMenuPage, {
        {"normal", speedBoost, 1},
        {"1.2x", speedBoost, 1.2},
        {"1.5x", speedBoost, 1.5},
        {"2x", speedBoost, 2}
        }
    },
    {"About/Project Gutenberg", openAboutPage, {
        }
    }
}

function love.keyreleased(key)
    if key == 'j' or key == 'l' then
        ISDOWN_COUNTER = -10
    end
end

function settingsUpdtate(dt)
    if MENUS[1] then
        Timer.update(dt*PREFS.speed)
    end
    if MENUS[1] then
        for i,v in ipairs(MENUS) do
            v.backButton:onHover(dt)  
            if v.buttons then               
                for _,w in ipairs(v.buttons) do
                    w:onHover(dt)
                end
            end
        end
        if KEYBOOL == true then
            if MENUS[#MENUS].buttons then
                for _,v in ipairs(MENUS[#MENUS].buttons) do
                    if v.cursor == true then
                        v.button_opacity = 0.3
                    else
                        v.button_opacity = 0
                    end
                end
            end
        end
    end
    if FOLDER.modals then
        for _,v in ipairs(FOLDER.modals) do
            v:onHover(dt)
        end
        for _,v in ipairs(FOLDER.entries) do
            v:onHover(dt)
        end
        if KEYBOOL == true then
            for _,v in ipairs(FOLDER.entries) do
                if v.cursor == true then
                    v.inView = true
                    v.button_opacity = 0.3
                else
                    --v.button_opacity = 0
                end
            end
        end
    end
    if INFOWINDOWS and INFOWINDOWS[1] then               
        for _,v in ipairs(INFOWINDOWS) do 
            if v.infoWindowButtons then
                for _,w in ipairs(v.infoWindowButtons) do 
                    w:onHover(dt)
                    if w.franzegramVar and w.franzegramVar.cursor then
                        w.franzegramVar:draw()
                        if #INFOWINDOWS > 2 then
                            if love.keyboard.isDown('j') then
                                if ISDOWN_COUNTER > 0 and ISDOWN_COUNTER % 2 == 0 then
                                    w.franzegramVar:onPress('j')
                                end
                                ISDOWN_COUNTER = ISDOWN_COUNTER + 1
                            elseif love.keyboard.isDown('l') then
                                if ISDOWN_COUNTER > 0 and ISDOWN_COUNTER % 2 == 0 then
                                    w.franzegramVar:onPress('l')
                                end
                                ISDOWN_COUNTER = ISDOWN_COUNTER + 1
                            end
                        end
                    end
                end
            end
        end
    else
        if SET_BOOK.modals then
            for _,v in ipairs(SET_BOOK.modals) do
                v:onHover(dt) 
            end
            for _,v in ipairs(SET_BOOK.entries) do
                v:onHover(dt) 
            end
            if KEYBOOL == true then
                for _,v in ipairs(SET_BOOK.entries) do
                    if v.cursor == true then
                        v.button_opacity = 0.3
                        v.inView = true
                    end
                end
            end
        end
        if SUBJECTS.page then
            for _,v in ipairs(SUBJECTS.modals) do 
                v:onHover(dt) 
            end
            for _,v in ipairs(SUBJECTS.entries) do 
                v:onHover(dt) 
            end
            if KEYBOOL == true then
                for _,v in ipairs(SUBJECTS.entries) do
                    if v.cursor == true then
                        v.inView = true
                        v.button_opacity = 0.3
                    end
                end
            end
        end
    end
end

function drawSettings()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(FONT.courier)
    for i,v in ipairs(MENUS) do
        love.graphics.setColor(1,1,1)
        v.page:draw()
        love.graphics.setColor(0,0.7,0)
        v.backButton:draw() 
        if v.buttons then
            for j,w in ipairs(v.buttons) do
                w:draw()
            end
        end
        if v.draw then
            v:draw()
        end
    end
    if FOLDER.modals then
        FOLDER.folder:draw()
        for _,v in ipairs(FOLDER.entries) do
            v:draw()
        end
        FOLDER.headers:draw()
        for _,v in ipairs(FOLDER.modals) do
            v:draw()
        end
    end
    if SET_BOOK.page then
        BOOKARRIVED = BOOKARRIVED + 1
        SET_BOOK.page:draw()
        local text = 'empty'
        local topTest = false
        local bottomTest = false
        for i,v in ipairs(SET_BOOK.entries) do
            if i == 1 and v.inView == false then
                topTest = true
            end
            if i == #SET_BOOK.entries and v.inView == false then
                bottomTest = true
            end
        end
        if topTest and bottomTest then
            text = 'SCROLL DOWN/UP'
        elseif topTest then
            text = 'SCROLL UP'
        elseif bottomTest then
            text = 'SCROLL DOWN'
        end
        if text ~= 'empty' then
            SET_BOOK.footer:draw(text)    
        end
        for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do
            v:draw()
        end
--[[         for _,v in ipairs(SET_BOOK.textSeen) do
            v:draw()
        end ]]
        for i,v in ipairs(SET_BOOK.entries) do
            v:draw()
        end
        for i,v in ipairs(SET_BOOK.modals) do
            v:draw()
        end
    end
    if SUBJECTS.entries then
        SUBJECTS.page:draw()
        VSUBJARRIVED = VSUBJARRIVED + 1
        for _,v in ipairs(SUBJECTS.entries) do 
            v:draw()
        end
        local text = 'empty'
        local topTest = false
        local bottomTest = false
        for i,v in ipairs(SUBJECTS.entries) do
            if i == 1 and v.inView == false then
                topTest = true
            end
            if i == #SUBJECTS.entries and v.inView == false then
                bottomTest = true
            end
        end
        if topTest and bottomTest then
            text = 'SCROLL DOWN/UP'
        elseif topTest then
            text = 'SCROLL UP'
        elseif bottomTest then
            text = 'SCROLL DOWN'
        end
        if text ~= 'empty' then
            SET_BOOK.footer:draw(text)    
        end
        for _,v in ipairs(SUBJECTS.modals) do
            v:draw()
        end
    end
    if INFO and INFO.draw then
        INFO:draw()
    end
    if INFOWINDOWS and INFOWINDOWS[1] then
        INFO_COUNTER = INFO_COUNTER + 1
        for _,v in ipairs(INFOWINDOWS) do
            v:draw()
            if v.infoWindowButtons then
                for _,w in ipairs(v.infoWindowButtons) do
                    w:draw()
                    if w.franzegramVar and w.franzegramVar.onPress then
                        w.franzegramVar:draw()
                    end
                end
            end
        end
        if FRANZEGRAMVAR and FRANZEGRAMVAR.draw then
            FRANZEGRAMVAR:draw()
        end
    end
    love.graphics.setColor(1,1,1)
end

function showSettings()
    showSettingsPage = true
    table.insert(MENUS, openMenuPage(BUTTONS))
    if READER and READER.readButtons then
        for _,v in ipairs(READER.readButtons) do
            v:hide()
        end
    end
end

function closeSubjects(del)
    local num = #SUBJECTS.entries
    local delay2 = 0.01
    local period = 0.2
    local delay = 0.1
    for i,v in ipairs(SUBJECTS.entries) do
        local delayTemp = v:close(period,delay*(#SUBJECTS.entries-i)+0.01)
        if i == 1 then
            delay2 = delayTemp
        end
    end
    for _,v in ipairs(SUBJECTS.modals) do 
        v:hide(period*2,delay)
    end
    local delay3 = SUBJECTS.page:close(period,delay2)
    for _,v in ipairs(SET_BOOK.modals) do
        v:reappear(period,delay2)        --period,delay
    end
    local clock = delay3
    Timer.after(clock, function() SUBJECTS = {} end)
    return clock
end


function hideSettings()
    local del = 0.4
    local delay = 0.01
    if SUBJECTS.page then
        delay = closeSubjects()
        delay = closeBooks(delay)
        delay = closeFolder(delay)
        delay = closeMenu(delay)
    elseif SET_BOOK.page then
        delay = closeBooks(delay) 
        delay = closeFolder(delay)
        delay = closeMenu(delay)
    elseif FOLDER.modals then
        delay = closeFolder(delay)
        delay = closeMenu(delay)
    else
        delay = closeMenu(delay)
    end
    Timer.after(delay,function() 
        showSettingsPage = false 
        MENUS = {}
        if READER and READER.readButtons then
            for _,v in ipairs(READER.readButtons) do
                v:reappear()
            end
        end
    end)
end

function closeMenu(inDelay)
    local inDelay = inDelay or 0
    local period = 0.2
    local delay = 0.2 
    local k = 0
    local outDelay = 0.01
    local buttonDelay = 0.01
    for i = #MENUS, 1, -1 do
        k = k+1
        for j,w in ipairs(MENUS[i].buttons) do
            local buttonDelayTemp = w:close(period,(#MENUS[i].buttons-j)*0.1+inDelay+outDelay)
            if j == 1 then 
                buttonDelay = buttonDelayTemp
            end
        end
        outDelay = MENUS[i].page:close(period,(k-1)*0.1+buttonDelay)
        Timer.after((k-1)*0.1+buttonDelay-0.2, function() 
            if MENUS and MENUS[i] and MENUS[i].backbutton and MENUS[i].backbutton.close then 
                MENUS[i].backButton:close()
            end  
        end)
    end
    return (k-1)*0.1 + inDelay + outDelay
end


function activeSettingsTest(v)
    local tester = v.func_params or v[3]
    local txt = v.func or v[2]
    local kSet = false
    if txt == searchTarget then
        if tester == PREFS.search then
            kSet = true
        end
    elseif txt == sizePassage then
        if tester == PREFS.size then
            kSet = true
        end
    elseif txt == speedBoost then
        if tester == PREFS.speed then
            kSet = true
        end
    elseif txt == skipAhead then
        if tester == PREFS.skip then
            kSet = true
        end
    end
    return kSet
end

--- My Folder functions

function getFolder()
    local x = -75
    local origin_y = DRAW_HEIGHT
    local y = origin_y
    local target_y = -20
    local scale = 3
    local period = 0.2

    return {
        x = x,
        y = y,
        target_y = target_y,
        scale = scale,
        period = period,
        origin_y = origin_y,

        open = function(self)
            Timer.tween(self.period,self, {y = self.target_y})
            return self.period
        end,

        close = function(self, period,delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period, self, {y = self.origin_y})
            end)
            return period + delay
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(setPageFaded,self.x, self.y,nil,self.scale)
        end
    }
end

function getFolderEntries(i,v, num,count)
    local first = false
    if i == 1 then
        first = true
    end
    local last = false
    if i == count then
        last = true
    end
    local entryTempL = ''
    local entryTempR = ''
    local tempA = ''
    local tempA1 = ''
    local tempT = ''
    local tempT1 = ''
    local tempTitle = ''
    local tempAuthor = ''
    local tempNum = ''
    local tempText = ''
    local entries = #v.readChapters
    local tText = ''
    local baseText = ''
    if v.readChapters and v.readChapters[1] and v.readChapters[1].txt then
        baseText = v.readChapters[1].txt
    else
        baseText = v.first500
    end
    local _,z = string.find(baseText, "\n\n")
    if z then
        tText = string.sub(baseText, z+1)
    else
        tText = baseText
    end
    if string.find(tText, "\n\n") then
        tempText = tText:gsub("\n\n", " ")
    else
        tempText = tText
    end
    if string.find(v.author, "\n\n") then
        tempA1 = v.author:gsub("\n\n", " ")
        tempA = tempA1:gsub(" +", " ")
    else
        tempA1 = v.author
        tempA = tempA1:gsub(" +", " ")
    end
    if string.find(v.title, "\n") or string.find(v.title, "\r") then
        tempT1 = v.title:gsub("\n", " ")
        tempT2 = tempT1:gsub("\r", " ")
        tempT = tempT2:gsub(" +", " ")
    else
        tempT1 = v.title
        tempT = tempT1:gsub(" +", " ")
    end
    entryTempL = '"'..tempText:sub(1,90)..'..."'
    if tempT:len() > 30 then
        tempTitle = tempT:sub(1,20)..'...'
    else
        tempTitle = tempT
    end
    if tempA:len() > 18 then
        tempAuthor = tempA:sub(1,18)..'...'
    else
        tempAuthor = tempA
    end
    entryTempR = tempTitle.."/"..tempAuthor
    tempNum = num..'. '
    local opacity = 0
    local num_x = 20
    local entryL_x = 60
    local entryR_x = 60
    local red = 0
    local green = 0.7
    local blue = 0
    local button_opacity = 0
    local cursor = false
    if i == 1 then
        cursor = true
    end
    local button_y = 180+(i-1)*140
    local text_y = button_y
    local top = 180
    local step_y = 140
    local inView = false
    if i <= 3 then
        inView = true
    end
    local drawHeight = 600
    local period = 0.2

    return {
        entries = entries,
        num = tempNum,
        entryL = entryTempL,
        entryR = entryTempR,
        index = i,
        func = showBook,
        opacity = opacity,
        num_x = num_x,
        entryL_x = entryL_x,
        entryR_x = entryR_x,
        width = width or DRAW_WIDTH,
        height = height or 100,
        button_x = 0,
        button_y = button_y,
        text_y = text_y,
        red = red,
        green = green,
        blue = blue,
        button_opacity = button_opacity,
        cursor = cursor,
        top = top,
        step_y = step_y,
        inView = inView,
        drawHeight = drawHeight,
        period = period,
        first = first,
        last = last,

        open = function(self)
            Timer.after((self.index-1)*0.2, function() Timer.tween(0.2, self, {opacity = 1}) end)
        end,

        close = function(self, period,delay)
            local period = period or self.period 
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period, self, {opacity = 0})
            end)
            return period + delay 
        end,

        onHover = function(self, dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if my >= self.button_y and my <= self.button_y + self.height then
                    local bool = true
                    self:showButton(bool)
                else
                    self:showButton()
                end
            end
        end,

        getCursor = function(self,bool)
            if bool then
                self.cursor = true
                self:showButton(bool)
            else
                self.cursor = false
                self:showButton()
            end
        end,

        showButton = function(self,bool)
            if bool then
                self.button_opacity = 0.3
            elseif self.cursor == false then
                self.button_opacity = 0
            end
        end,

        onClick = function(self, mouse_x, mouse_y)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    if self.inView then
                        self.func(self.index)
                    end
                end
            end 
        end,

        onEnter = function(self)
            self.func(self.index)
        end,

        draw = function(self)
            if self.inView then
                love.graphics.setColor(self.red,self.green,self.blue,self.button_opacity)
                love.graphics.rectangle('fill',self.button_x,self.button_y,self.width,self.height)
                love.graphics.setColor(0,0,0,self.opacity)
                love.graphics.printf(self.num, self.num_x, self.button_y,760,'left' )
                love.graphics.printf(self.entryL, self.entryL_x, self.text_y, 720,'left')
                love.graphics.printf(self.entryR, self.entryR_x, self.text_y + 75, 720,'right')
            end
        end
    }
end

function getCloseButton(func,modals,entries)
    local opacity = 0
    local button_opacity = 0
    local x = 10
    local y = 10
    local height = 25
    local width = 75
    local red = 0
    local green = 1
    local blue = 0
    local func = func
    local funcTest = tostring(func)
    local period = 0.2
    local active = true
    local letter = 'u'
    local keyTestBool = false
    local closeBool = true

    return {
        x = x,
        y = y,
        height = height,
        width = width,
        button_x = 7,
        button_y = 8,
        opacity = opacity,
        button_opacity = button_opacity,
        red = red,
        green = green,
        blue = blue,
        func = func,
        period = period,
        funcTest = funcTest,
        active = active,
        letter = letter,
        keyTestBool = keyTestBool,
        modals = modals,
        entries = entries,
        closeBool = closeBool,

        open = function(self)
            Timer.tween(self.period,self,{opacity = 1})
            return self.period
        end,

        close = function(self,period,delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity = 0})
            end)
            return period + delay 
        end,

        onHover = function(self,dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if my >= self.button_y and my <= self.button_y + self.height then
                    self.button_opacity = 0.3
                else
                    self.button_opacity = 0
                end
            end
        end,

        modalClick = function(self, mouse_x, mouse_y)
            CBARRIVED = CBARRIVED + 1
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    CBMATCHED = CBMATCHED + 1
                    self.func()
                end
            end 
        end,

        onPress = function(self,key)
            if self.active then
                if key == letter then
                    self.func()
                end
            end
        end,

        switchNav = function(self)

        end,

        keyTest = function(self,key)
            if key == 'i' then
                if not self.keyTestBool then
                    self.keyTestBool = true
                    self.iLast = true
                    self:deactivate()
                    return
                elseif self.keyTestBool and self.iLast then
                    self.keyTestBool = false
                    self.iLast = false
                    self:activate()
                    return
                else
                    self.iLast = true
                end
            elseif self.keyTestBool and key == self.letter then
                self.iLast = false
                self:buttonPressed()
                self:buttonReleased()
                if INFO and INFO.keys and INFO.keys.glow then 
                    for _,v in ipairs(INFO.keys) do
                        v:glow(key,0.1)
                    end
                end
            else
                self.iLast = false
            end
        end,

        toSleep = function(self,flag)
            if flag == self.sleepFlag then
                self:deactivate()
                self.opacity=0.3
                self.sleep = true
            elseif self.sleep then
                self:activate()
                self.opacity=1
                self.sleep = false
            end
        end,

        deactivate = function(self)
            self.active = false
        end,

        activate = function(self)
            self.active = true
        end,

        buttonPressed = function(self)
            self.button_opacity = 0.3
        end,

        buttonReleased = function(self)
            Timer.tween(0.2,self,{button_opacity=0})
        end,

        hide = function(self)
            Timer.tween(0.2,self,{opacity=0},'in-quint')
            self:deactivate()
        end,

        reappear = function(self,period,delay)
            local period = period or 0.2 
            local delay = delay or 2
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity=1},'in-quint')
                self:activate()
            end)
        end,


        onEnter = function(self)
            if self.active then
                self.func()
            end
        end,

        draw = function(self)
            love.graphics.setColor(self.red,self.green,self.blue,self.button_opacity)
            love.graphics.rectangle('fill',self.button_x,self.button_y,self.width,self.height)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.printf('CLOSE', FONT.courier,self.x,self.y,600,'left')
        end
    }
end

function getHeaders()
    local opacity = 0
    local text_x = 20
    local topText_y = 50
    local text_width = 760
    local bottomText_y = 100
    local period = 0.2

    return {
        opacity = opacity,
        text_x = text_x,
        topText_y = topText_y,
        text_width = text_width,
        bottomText_y = bottomText_y,
        period = period,

        open = function(self)
            Timer.tween(self.period,self,{opacity = 1})
            return self.period
        end,

        close = function(self,period,delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity = 0})
            end)
            return period + delay
        end,

        draw = function(self)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.printf('Click # for details',self.text_x,self.topText_y,self.text_width,'center')
            love.graphics.printf('PASSAGES', FONT.courier,self.text_x,self.bottomText_y,self.text_width,'left')
            love.graphics.printf('BOOK/AUTHOR', FONT.courier,self.text_x,self.bottomText_y,self.text_width,'right')
        end
    }
end

function closeBooks(inDelay)
    local inDelay = inDelay or 0
    local delay = 0.1
    local period = 0.2
    for _,v in ipairs(FOLDER.modals) do
        v:reappear(period,inDelay+delay)
    end
    local delay2 = 0.01
    for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do
        delay2 = v:close(period,inDelay+delay)
    end
    local delay4 = 0.01
    SET_BOOK.footer:close(period,inDelay+delay)
    for i,v in ipairs(SET_BOOK.entries) do
        local delayTemp = v:close(period,inDelay+delay*(#SET_BOOK.entries-i)+0.01)
        if i == 1 then
            delay4 = delayTemp
        end
    end
    local delay3 = SET_BOOK.page:close(period,delay2,delay4)
    local clock = math.max(delay4, delay3)
    Timer.after(clock, function() SET_BOOK = {} end)
    return clock
end

function closeFolder(delay)
    TWICON:fromSettings()
    local delay = delay or 0.01
    local period = period or 0.3
    CLOSEFOLDERARRIVED = CLOSEFOLDERARRIVED + 1
    local baseNum = #FOLDER.entries
    local delay1 = 0.01
    local lastInView = 0
    if baseNum > 3 then 
        baseNum = 3
        for i,v in ipairs(FOLDER.entries) do 
            if v.inView then
                lastInView = i
            end
        end
    end
    for i,v in ipairs(FOLDER.entries) do
        if i == lastInView - 1 then 
            i = 2 
        elseif i == lastInView - 2 then 
            i = 1
        else
            i = 3
        end
        local delayTemp = v:close(period,(baseNum-i)*0.1+delay)
        if i == 1 then 
            delay1 = delayTemp
        end
    end
    for i,v in ipairs(FOLDER.modals) do
        v:hide(period*2,delay1)
    end
    local delay2 = FOLDER.headers:close(period, delay1)
    local delay3 = FOLDER.folder:close(period+0.2, delay2)
    local num = math.min(3, #FOLDER.entries)
    Timer.after(delay3, function() FOLDER = {} end)
    return delay3
end

function showBook(index)
    if USERDATA[index].textSeen and USERDATA[index].textSeen[1] then
        local last = #USERDATA[index].textSeen
        table.remove(USERDATA[index].textSeen)
        table.insert(USERDATA[index].textSeen, formatTextSeen(index,last))
    else
        local textSeen = formatTextSeen(index)
        table.insert(USERDATA[index].textSeen, textSeen)
        USERDATA[index].textSeenChapter = 1 
--[[         for _,page in ipairs(textSeen) do 
            table.insert(USERDATA[index].textSeen, page)
        end ]]
    end
    for _,v in ipairs(USERDATA[index].textSeen[USERDATA[index].textSeenChapter]) do 
        v:open()
    end
    local footer = getDetailsFooter()
    footer:open()
    local closeButton = getCloseButton(closeBooks)
    closeButton:open()
    local page = getBookPage()
    page:open()
    bookDetailsLayout({{USERDATA[index].title, 'TITLE: '},{USERDATA[index].author, 'AUTHOR: '},{tostring(USERDATA[index].dls), 'DOWNLOADS/MO.: '},{tostring(USERDATA[index].date), 'UPLOADED ON: '},{USERDATA[index].subject, 'SUBJECTS: '},{USERDATA[index].link, 'LINK: '}},index,page,footer,textSeen,USERDATA[index].title)
end

function getMoreTextSeen(bookIndex,chNum)
    if #USERDATA[bookIndex].textSeen < chNum + 1 then 
        if #USERDATA[bookIndex].readChapters >= chNum + 1 then
            local textSeen = formatTextSeen(bookIndex,chNum+1)
            table.insert(USERDATA[bookIndex].textSeen,textSeen)
        end
    end
end

function textSeenChapterForward()
    local delay = 0.01
    if USERDATA[SET_BOOK.index].textSeenChapter < #USERDATA[SET_BOOK.index].readChapters then 
        for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
            delay = v:close()
        end
        Timer.after(delay, function()
            USERDATA[SET_BOOK.index].textSeenChapter = USERDATA[SET_BOOK.index].textSeenChapter + 1
            for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
                table.insert(SET_BOOK.textSeen, v) 
            end
            for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
                v:open()
            end
        end)
    end
end

function textSeenChapterBack()
    local delay = 0.01
    print('textSeenChapterBack 1')
    if USERDATA[SET_BOOK.index].textSeenChapter > 1 then
        print('textSeenChapterBack 2')
        for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
            delay = v:close()
        end
        USERDATA[SET_BOOK.index].textSeenChapter = USERDATA[SET_BOOK.index].textSeenChapter - 1
        Timer.after(delay, function()
--[[             for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
                table.insert(SET_BOOK.textSeen, v) 
            end ]]
            for i,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
                v:open()
                if i == 1 then 
                    v:scrollOn()
                    v.cursor = true
                    print(i,'scrollOn textSeenChapterBack')
                else
                    v.cursor = false
                    print(i,'scrollOff textSeenChapterBack')
                    v:scrollOff()
                end
            end
        end)

    end
end

function getDetailsFooter(pageTotal)
    local y = 480
    local y2 = 500
    local x = 0
    local limit = DRAW_WIDTH/2 
    local page = 1
    local textDown = 'SCROLL DOWN'
    local textDownUp = 'SCROLL DOWN/SCROLL UP'
    local textUp = 'SCROLL UP'
    local textMore = 'for more'
    local opacity = 0
    local cursor = 1
    local period = 0.2

    return {
        y = y,
        y2 = y2,
        x = x,
        page = page,
        pageTotal = pageTotal,
        opacity = opacity,
        limit = limit,
        cursor = cursor,
        textMore = textMore,
        period = period,

        open = function(self)
            Timer.tween(0.2,self,{opacity = 1})
        end,

        close = function(self, period, delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity = 0})
            end)
            return period + delay 
        end,

        scrollUp = function(self)
            self.opacity = 0
            self.page = self.page - 1
            Timer.tween(0.1,self,{opacity = 1})
        end,

        draw = function(self,text)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.printf(text,FONT.courier, self.x,self.y,self.limit,"center")
            love.graphics.printf(self.textMore, FONT.courier, self.x,self.y2,self.limit,"center")
        end
    }
end

function getReadPagesText(index,chNum) 
    local tempString = ''
    local pageTable = {}
    local chNum = chNum or 1
    for _,page in ipairs(USERDATA[index].readChapters[chNum].pages) do 
        if page.seen == false then 
            goto concatNext
        else
            tempString = string.gsub(page.text, '^%s*(.-)%s*$', '%1')
            table.insert(pageTable, tempString)
            tempString = ''
        end
    end
    ::concatNext::
    local concatText = table.concat(pageTable, ' ')
    local tText = ''
    local _,z = string.find(concatText, "\n\n")
    if z then
        tText = string.sub(concatText, z+1)
    else
        tText = concatText
    end
    return tText..'\n\n ### '
end

function getTwPagesText(index)
    local tempString = ''
    local pageTable = {}
    local chapterTable = {}
    local bookmark_bool = true 
    for i, chapter in ipairs(USERDATA[index].twChapters) do
        for j,page in ipairs(chapter) do
            for k,line in pairs(page) do
                if i < USERDATA[index].bookmark_tw.chapter or j < USERDATA[index].bookmark_tw.pageCount then
                    tempString = string.gsub(line, '^%s*(.-)%s*$', '%1')..' '
                    table.insert(pageTable, tempString)
                    tempString = ''
                elseif bookmark_bool and USERDATA[index].bookmark_tw.rumpText then
                    tempString = string.gsub(USERDATA[index].bookmark_tw.rumpText, '^%s*(.-)%s*$', '%1')
                    table.insert(pageTable, tempString)
                    tempString = ''
                    bookmark_bool = false
                end
            end
        end
        table.insert(chapterTable, table.concat(pageTable))
        pageTable={}
    end
    local concatText = table.concat(chapterTable, ' ### ')
    local tText = ''
    local _,z = string.find(concatText, "\n\n")
    if z then
        tText = string.sub(concatText, z+1)
    else
        tText = concatText
    end
    return tText
end

function formatTextSeen(index,chNum)
    local tText1 = ''
    local tText2 = ''
    local tText = ''
    local chNum = chNum or 1
    if USERDATA[index].readChapters and USERDATA[index].readChapters[1] then
        tText1 = getReadPagesText(index,chNum)
    end
    if USERDATA[index].twChapters and USERDATA[index].twChapters[1] then
        tText2 = getTwPagesText(index) 
    end
    if tText1 then
        if tText2 then 
            if #tText1 > #tText2 then
                tText = tText1 
            else
                tText = tText2
            end
        else
            tText = tText1
        end
    elseif tText2 then 
        tText = tText2 
    else
        tText = ''
    end
    local pages = textWrapPassages(tText, 14, DRAW_HEIGHT-270,chNum)
    local formatPages = {}
    if type(pages) == 'string' then
        table.insert(formatPages, getTextSeen(pages,1,1))
    else
        for i,v in ipairs(pages) do
            table.insert(formatPages, getTextSeen(v,i,#pages,index,chNum))
        end
    end
    return formatPages
end

function getTextSeen(text, index,pageTotal,bookIndex,chNum)
    local footer_y = DRAW_HEIGHT - 120
    local footer_x = DRAW_WIDTH/2
    local footer_limit = DRAW_WIDTH/2
    local opacity = 0
    local x = 420
    local y = 50
    local cursor = false
    local first = false
    local last = false
    if index == 1 and chNum == 1 then
        cursor = true
        first = true
    elseif index == pageTotal then
        last = true
    end
    local period = 0.2
    local moreTextBool = true

    return {
        opacity = opacity,
        text = text,
        x = x,
        y = y,
        index = index,
        cursor = cursor,
        footer_x = footer_x,
        footer_y = footer_y,
        footer_limit = footer_limit,
        pageTotal = pageTotal,
        first = first,
        last = last,
        period = period,
        bookIndex = bookIndex,
        moreTextBool = moreTextBool,
        chNum = chNum,

        open = function(self)
            if self.index == 1 then 
                self.cursor = true
                Timer.after(0.4, function()
                    Timer.tween(0.5, self,{opacity = 1},'out-cubic')
                end)
            end
        end,

        getCursor = function(self,bool,key)
            if self.cursor and key and key == 'l' and self.index == self.pageTotal then 
                print('settings textSeenChapterForward called')
                textSeenChapterForward()
            end
            if self.cursor and key and key == 'j' and self.index == 1 then 
                print('settings textSeenChapterBack called')
                textSeenChapterBack()
            end
            if bool then
                self.cursor = true
            else
                self.cursor = false
            end
        end,

        close = function(self, period, delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity = 0},'out-cubic')
            end)
            return period + delay
        end,

        scrollOn = function(self)
            Timer.tween(0.1,self,{opacity = 1})
            if self.index == self.pageTotal then 
                getMoreTextSeen(self.bookIndex,self.chNum)
            end
        end,

        scrollOff = function(self)
            self.opacity = 0
        end,

        jumpTo = function(self,index)
            if index == self.index then
                self:scrollOn()
            else
                self:scrollOff()
            end
        end,

        draw = function(self)
            love.graphics.setFont(FONT.courier)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.print(self.text, self.x,self.y)
            if self.chNum then
                love.graphics.printf('CH '..self.chNum..' / '..'PAGE '..self.index..' OF '..self.pageTotal,self.footer_x,self.footer_y,self.footer_limit,"center")
            end
        end
    }  
end

function getBookPage()
    PAGEARRIVED = PAGEARRIVED + 1
    local left_x_origin = -1500
    local right_x_origin = -1000
    local left_x_target = -1000
    local right_x_target = -500
    local left_x = left_x_origin
    local right_x = right_x_origin
    local y = -20
    local scale = 3
    local period = 0.2

    return {
        left_x = left_x,
        right_x = right_x,
        left_x_origin = left_x_origin,
        right_x_origin = right_x_origin,
        left_x_target = left_x_target,
        right_x_target = right_x_target,
        y = y,
        scale = scale,
        period = period,

        open = function(self)
            PAGEOPENARRIVED = PAGEOPENARRIVED + 1
            Timer.tween(self.period,self,{left_x = self.left_x_target}, 'out-cubic', function()
                Timer.after(0.2, function()
                    Timer.tween(self.period,self,{right_x = self.right_x_target}, 'out-cubic')
                end)
            end)
            return self.period*2+0.2
        end,

        close = function(self, period, delay,delay2)
            local period = period or self.period
            local delay = delay or 0.01
            local delay2 = delay2 or 0.2
            Timer.after(delay,function()
                Timer.tween(period,self,{right_x = self.right_x_origin}, 'in-cubic', function()
                    Timer.after(delay2-delay, function()
                        self.right_x = self.left_x_origin
                        Timer.tween(period,self,{left_x = self.left_x_origin}, 'in-cubic')
                    end)
                end)
            end)
            return period*2 + delay2 
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(setPageFaded,self.right_x, self.y,nil,self.scale)
            love.graphics.draw(setPageFaded,self.left_x, self.y,nil,self.scale)
        end
    }
end

function bookDetailsLayout(details,index,page,footer,textSeen,title)
    local yPos = 100
    local text = ''
    local lines = 1
    local func
    local func_params = ''
    local v3 = ''
    local v2 = ''
    local char = 14
    local red = 1
    local green = 0
    local bookDetails = {}
    local index = index
    local count = #details
    for i,v in ipairs(details) do
        if v[2] then
            if v[2] == 'LINK: ' then
                func = love.system.openURL
                func_params = v[1]
                green = 1
                red = 0
                text, lines = textWrap(v[2]..v[1], char,i)
            elseif type(v[1]) == "string" then
                if string.find(v[1], "\n") or string.find(v[1], "\r") then
                    if string.find(v[1], "\n") then
                        v2 = v[1]:gsub("\n", "/")
                    else
                        v2 = v[1]
                    end
                    if string.find(v2, "\r") then
                        v3 = v2:gsub("\r", "/")
                    else
                        v3 = v2
                    end
                else
                    v3 = v[1]
                end
                text, lines = textWrap(v[2]..v3, char, i)
            elseif type(v[1]) == "table" then
                local removeIndex = {}
                for j,w in ipairs(v[1]) do
                    if #w == 2 then
                        table.insert(removeIndex, j)
                    end
                end
                if removeIndex[1] then
                    table.remove(v[1], removeIndex[1])
                end
                if #v[1] == 2 then
                    text, lines = textWrap(v[2]..v[1][1]..' // '..v[1][2], char,i)
                elseif #v[1] == 3 then
                    text, lines = textWrap(v[2]..v[1][1]..' // '..v[1][2]..' // '..v[1][3], char,i)
                elseif #v[1] > 3 then
                    text, lines = textWrap(v[2]..v[1][1]..' // '..v[1][2]..' // '..v[1][3]..' (see more)', char,i)
                    func = seeMore
                    green = 1
                    red = 0
                    func_params = {v[1],'subj'}
                else
                    text, lines = textWrap(v[2]..v[1][1], char,i)
                end
            end
        else
            text = '(missing)'
            lines = 1
        end
        table.insert(bookDetails, getBookDetails(text,yPos,lines,func,func_params,red,green,i,count))
        yPos = yPos + (lines+1)*25
    end
    local textSeen = {}
    SET_BOOK = {
        entries = bookDetails,
        textSeen = textSeen,
        page = page,
        footer = footer,
        index = index,
        modals = {
        getButton({ICONS.upArrow},scrollUp,'params',DRAW_WIDTH*0.25,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.15,DRAW_HEIGHT*0.04,COLORS.pink,{20},{FONT.roboto},4,{},{bookDetails,'textSeen'}),         --USERDATA[index].textSeen[USERDATA[index].textSeenChapter]
        getButton({ICONS.check},selectThis,'params',DRAW_WIDTH*0.45,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.1,DRAW_HEIGHT*0.04,COLORS.green,{20},{FONT.roboto},5,{},{bookDetails,'textSeen'}),
        getButton({ICONS.downArrow},scrollDown,'params',DRAW_WIDTH*0.6,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.15,DRAW_HEIGHT*0.04,COLORS.lightpurple,{20},{FONT.roboto},6,{},{bookDetails,'textSeen'}),
        navButton(DRAW_WIDTH*0.25,DRAW_HEIGHT*0.9,DRAW_WIDTH*0.5,DRAW_HEIGHT*0.04,COLORS.crimson,FONT.roboto,3,{},bookDetails),
        getInfoButton(DRAW_WIDTH*0.95,DRAW_HEIGHT*0.965,24,COLORS.crimson,{},bookDetails),
        -- getButton({'Franze-','grams'},infoWindowManager,{"Franzegrams\n\nChoose a text. Share it in a gif.",{{"Continue ('k')",'k'},{"Close ('u')",'u'}},DRAW_WIDTH*0.1+DRAW_WIDTH*0.125/2,DRAW_HEIGHT*0.9+DRAW_HEIGHT*0.1/2,{franzegram,closeInfoWindows},{textSeen,'params'},'left'},DRAW_WIDTH*0.1,DRAW_HEIGHT*0.9,DRAW_WIDTH*0.125,DRAW_HEIGHT*0.1,COLORS.darkpurple,{20,20},{FONT.roboto,FONT.roboto},7,{},{bookDetails,textSeen}),
        getButton({'Reopen','book'},infoWindowManager,{'Re-open '..title..'?',{{"yes ('k')",'k'},{"no/close ('u')",'u'}},DRAW_WIDTH*0.775+DRAW_WIDTH*0.125/2,DRAW_HEIGHT*0.9+DRAW_HEIGHT*0.1/2,{reopenBook,closeInfoWindows},{index,'params'},'full'},DRAW_WIDTH*0.775,DRAW_HEIGHT*0.9,DRAW_WIDTH*0.125,DRAW_HEIGHT*0.1,COLORS.red,{20,20},{FONT.roboto,FONT.roboto},8,{},{bookDetails,textSeen}),
        getCloseButton(closeBooks,{},bookDetails)
        }
    }
    for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[1]) do 
        table.insert(SET_BOOK.textSeen, v) 
    end
    for _,v in ipairs(SET_BOOK.modals) do
        v.modals = SET_BOOK.modals
    end
    for _,v in ipairs(SET_BOOK.modals) do
        v:open()
    end
    SET_BOOK.footer:open()
    for i,v in ipairs(SET_BOOK.entries) do
        Timer.after((i-1)*0.1, function()
            v:open()
        end)
    end
    for _,v in ipairs(FOLDER.modals) do 
        v:hide()
    end
end

function getBookDetails(text,yPos,lines,func,func_params,red,green,index,count)
    local index = index
    local text = text
    local lines = lines
    local func = func
    local func_params = func_params
    local red = red or 1
    local green = green or 0
    local opacity = 0
    local text_x = 20
    local text_y = yPos
    local button_x = 0
    local button_y = text_y - 2
    local width = 400
    local height = lines*28
    local blue = 0
    local button_opacity = 0
    local period = 0.2
    local subjects = {}
    local top = 100
    local step_y = height + 25 
    local cursor = false
    local first = false
    local last = false
    if index == 1 then
        cursor = true
        first = true
    elseif index == count then
        last = true
    end
    local drawHeight = 480
    local inView = false
    if button_y + height < (drawHeight) then
        inView = true
    end

    return {
        yPos = yPos,
        text = text,
        lines = lines,
        func = func,
        func_params = func_params,
        opacity = opacity,
        text_x = text_x,
        text_y = text_y,
        button_x = button_x,
        button_y = button_y,
        width = width,
        height = height,
        red = red,
        green = green,
        blue = blue,
        button_opacity = button_opacity,
        period = period,
        cursor = cursor,
        top = top,
        step_y = step_y,
        index = index,
        inView = inView,
        drawHeight = drawHeight,
        first = first,
        last = last,

        open = function(self)
            Timer.tween(self.period,self,{opacity = 1})
            return self.period
        end,

        close = function(self, period, delay)
            local period = period or self.period
            local delay = delay or 0.01
            NAVSWITCH = true
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity = 0})
            end)
            return period + delay
        end,

        onHover = function(self, dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if my >= self.button_y and my <= self.button_y + self.height then
                    local bool = true
                    self:showButton(bool)
                else
                    self:showButton()
                end
            end
        end,

        getCursor = function(self,bool)
            if bool then
                self.cursor = true
                self:showButton(bool)
            else
                self.cursor = false
                self:showButton()
            end
        end,

        showButton = function(self,bool)
            if bool then
                self.button_opacity = 0.3
            elseif self.cursor == false then
                self.button_opacity = 0
            end
        end,

        onClick = function(self, mouse_x, mouse_y)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    if self.inView then
                        if type(self.func_params) == 'table' then
                            if self.func_params[2] == 'subj' then
                                if self.func then
                                    SUBJCALLARRIVED = SUBJCALLARRIVED + 1
                                    self.func(self.func_params)  
                                end
                            end
                        elseif self.func_params then
                            if self.func then
                                self.func(self.func_params, self.text) 
                            end
                        elseif self.func then
                            self.func()
                        end
                    end
                end
            end
        end,

        onEnter = function(self)
            if type(self.func_params) == 'table' then
                if self.func_params[2] == 'subj' then
                    if self.func then
                        SUBJCALLARRIVED = SUBJCALLARRIVED + 1
                        self.func(self.func_params)  
                    end
                end
            elseif self.func_params then
                if self.func then
                    self.func(self.func_params, self.text) 
                end
            elseif self.func then
                self.func()
            end
        end,

        draw = function(self)
            if self.inView then
                love.graphics.setColor(self.red,self.green,self.blue,self.button_opacity)
                love.graphics.rectangle('fill',self.button_x,self.button_y,self.width,self.height)
                love.graphics.setFont(FONT.courier)
                love.graphics.setColor(0,0,0,self.opacity)
                love.graphics.print(self.text,self.text_x,self.text_y)
            end
        end,

        subjects = subjects
    }
end

function seeMore(sub)
    local subj = sub[1]
    local subjects = {}
    local yPos = 100
    local char = 14
    local text = ''
    local lines = 0
    local count = #subj
    for i,v in ipairs(subj) do
        text, lines = textWrap(v, 14,i)
        table.insert(subjects, getBookDetails(text,yPos,lines,nil,nil,nil,nil,i,count))
        yPos = yPos + (lines+1)*25
    end
    for i,v in ipairs(subjects) do 
        Timer.after((i-1)*0.1, function()
            v:open()
        end) 
    end
    local page = seeMorePage()
    page:open()
    local modals = {}
    local textSeen = {}
    SUBJECTS = {
        entries = subjects,
        page = page,
        modals = {
        getButton({ICONS.upArrow},scrollUp,'params',DRAW_WIDTH*0.1,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.3,DRAW_HEIGHT*0.04,COLORS.pink,{20},{FONT.roboto},4,{},{subjects,'textSeen'}),     --USERDATA[SET_BOOK.index].textSeen[SET_BOOK.index]}),
        getButton({ICONS.downArrow},scrollDown,'params',DRAW_WIDTH*0.6,DRAW_HEIGHT*0.95,DRAW_WIDTH*0.3,DRAW_HEIGHT*0.04,COLORS.lightpurple,{20},{FONT.roboto},6,{},{subjects,'textSeen'}),
        navButton(DRAW_WIDTH*0.1,DRAW_HEIGHT*0.9,DRAW_WIDTH*0.8,DRAW_HEIGHT*0.04,COLORS.crimson,FONT.roboto,3,{},subjects),
        getCloseButton(closeSubjects,{},subjects)
        } 
    }
    for _,v in ipairs(USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]) do 
        table.insert(SET_BOOK.textSeen, v) 
    end
    for _,v in ipairs(SUBJECTS.modals) do
        v.modals = SUBJECTS.modals
        v:open()
    end
    for _,v in ipairs(SET_BOOK.modals) do
        v:hide()
    end
end

function seeMorePage()
    local origin_x = -1500
    local x = origin_x
    local target_x = -1000
    local y = -20
    local scale = 3
    local period = 0.2 

    return {
        x = x,
        y = y,
        scale = scale,
        origin_x = origin_x,
        target_x = target_x,
        period = period,

        open = function(self)
            Timer.tween(0.3,self,{x = target_x},'out-cubic')
        end,

        close = function(self, period, delay)
            local period = period or self.period
            local delay = delay or 0.01
            Timer.after(delay,function() 
                Timer.tween(period,self,{x = origin_x},'in-cubic')
            end)
            return period + delay
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(setPageFaded,self.x,self.y,nil,3)
        end
    }
end

function textWrapPassages(rawText, char, pageHeight,chNum)
    local chNum = chNum or 1
    local char = char or 10
    local width1 = 260/800*DRAW_WIDTH
    local width2 = 350/800*DRAW_WIDTH
    local bigWord = 0
    local cursor = 0
    local lineCursor = 0
    local tempTextL = ''
    local tempTextR = ''
    local lineCount = 1
    local pageLineCount = 1
    local pageStart = 0
    local pages = {}
    local tillEnd = 0
    local text = '' 
    local header =  {'one','two','three','four','five','six','seven','eight','nine','ten','eleven','twleve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty','twenty-one','twenty-two','twenty-three','twenty-four','twenty-five','twenty-six','twenty-seven','twenty-eight','twenty-nine','thirty','thirty-one','thirty-two','thirty-three','thirty-four','thirty-five','thirty-six','thirty-seven','thirty-eight','thirty-nine','forty','forty-one','forty-two','forty-three','forty-four','forty-five','forty-six','forty-seven','forty-eight','forty-nine','fifty'}
    if chNum == 1 then 
        local rawText2 = 'TEXT SEEN: '..rawText
        text = rawText2:gsub("%s+", " ") 
    else 
        local rawText2 = 'TEXT SEEN: '..rawText
        text = rawText2:gsub("%s+", " ") 
        table.insert(pages, '\n\n\n\n\n\n\n   CHAPTER '..string.upper(header[chNum]))
    end
    local lineHeight = 26/600*DRAW_HEIGHT_ADJ
    local pageHeight = pageHeight or 490/600*DRAW_HEIGHT_ADJ
    local maxLine = math.floor(pageHeight/lineHeight)
    local maxChar = math.floor(width1/char)
    local txt = text
    local textCopy = txt
    -- 'addSpace' flag to correct for unsynching btw txt and textCopy needed to eliminate leading space from new page
    local addSpace = false
    for i in string.gmatch(textCopy, "%S+") do
        if pageLineCount > 2 then 
            maxChar = math.floor(width2/char)
        else
            maxChar = math.floor(width1/char)
        end
        if #i > maxChar then
            bigWord = #i
            while bigWord > maxChar do
                tillEnd = maxChar - lineCursor
                lineCount = lineCount + 1
                pageLineCount = pageLineCount + 1
                if pageLineCount > 2 then 
                    maxChar = math.floor(width2/char)
                else
                    maxChar = math.floor(width1/char)
                end
                bigWord = bigWord - tillEnd
                if bigWord > maxChar then
                    tempTextL = string.sub(txt, 1, cursor + tillEnd)
                    tempTextR = string.sub(txt, cursor + 1 + tillEnd)
                    cursor = cursor + tillEnd + 1
                    lineCursor = 1
                else
                    tempTextL = string.sub(txt, 1, cursor + 1 + tillEnd)
                    tempTextR = string.sub(txt, cursor + 2 + tillEnd)
                    cursor = cursor + tillEnd + 2 + bigWord
                    lineCursor = bigWord + 1
                end
                txt = ''
                txt = tempTextL..'\n'..tempTextR
                if pageLineCount == maxLine then
                    table.insert(pages, string.sub(txt, pageStart, cursor))
                    pageLineCount = 1
                    pageStart = cursor
                end
            end
            bigWord = 0
        else
            if pageLineCount > 2 then 
                maxChar = math.floor(width2/char)
            else
                maxChar = math.floor(width1/char)
            end
            if i == '###' then
                tempTextL = string.sub(txt, 1, cursor)
                tempTextR = string.sub(txt, cursor + 5)             
                txt = ''
                txt = tempTextL..'\n\n\n'..tempTextR 
                lineCount = lineCount + 3                           
                pageLineCount = pageLineCount + 3                   
                lineCursor = 0
                cursor = cursor + 3                                 
                if pageLineCount >= maxLine then
                    local diff = pageLineCount - maxLine
                    table.insert(pages, string.sub(txt, pageStart, cursor))
                    pageLineCount = 1 + diff
                    pageStart = cursor
                end
            elseif lineCursor + #i + 1 > maxChar + 1 then
                lineCount = lineCount + 1
                pageLineCount = pageLineCount + 1
                if addSpace then
                    tempTextL = string.sub(txt, 1, cursor - 1)
                    tempTextR = string.sub(txt, cursor - 1)
                    txt = ''
                    txt = tempTextL..' '..tempTextR
                    addSpace = false
                    cursor = cursor + 1
                end
                if pageLineCount == maxLine then
                    table.insert(pages, string.sub(txt, pageStart, cursor))
                    pageLineCount = 1
                    cursor = cursor
                    addSpace = true
                    pageStart = cursor + 1
                else
                    tempTextL = string.sub(txt, 1, cursor)
                    tempTextR = string.sub(txt, cursor + 1)
                    txt = ''
                    txt = tempTextL..'\n'..tempTextR
                end
                cursor = cursor + #i + 2
                lineCursor = #i + 1
            else
                cursor = cursor + #i + 1
                lineCursor = lineCursor + #i + 1
            end
        end
    end
    if pages[1] then
        table.insert(pages, string.sub(txt, pageStart, cursor))
        return pages, lineCount
    else
        return txt,lineCount
    end
end

function textWrap(txt, char, index, pageHeight)
    local char = char or 10
    local width = 360
    local cursor = 0
    local lineCursor = 0
    local tempTextL = ''
    local tempTextR = ''
    local textCopy = txt
    local bigWord = 0
    local tillEnd = 0
    local lineCount = 1
    local lineCheck = 0
    local lineHeight = 26
    local pageHeight = pageHeight or DRAW_HEIGHT - 50
    local maxLine = math.floor(pageHeight/lineHeight)
    if specifics then
        width = specifics[1].width
        if specifics[2] then
            lineCheck = specifics[2].lines 
        end
        table.remove(specifics, 1)
    end
    local lineBreaks = {}
    local returnCount = {}
    local breakStart = 0
    local breakEnd = 0
    local i = 1
    while true do
        breakStart, breakEnd = string.find(txt, '\n+', i)
        if breakStart then
            table.insert(lineBreaks, breakStart)
            i = breakEnd+1
            table.insert(returnCount, breakEnd - breakStart + 1)
        else
            break
        end
    end
    local maxChar = math.floor(width/char)
    local upperLimit = 2000000000
    local nextBreak = upperLimit
    if lineBreaks[1] then
        nextBreak = table.remove(lineBreaks, 1)
    end
    local pageLineCount = 1
    local pageStart = 0
    local pages = {}
    local leadBool = true
    for i in string.gmatch(textCopy, "%S+") do
        if #i > maxChar then
            bigWord = #i
            while bigWord > maxChar do
                tillEnd = maxChar - lineCursor
                tempTextL = string.sub(txt, 1, cursor + tillEnd)
                tempTextR = string.sub(txt, cursor + 2 + tillEnd)
                txt = ''
                txt = tempTextL..'\n'..tempTextR
                cursor = cursor + tillEnd
                lineCursor = 1
                bigWord = bigWord - tillEnd
                lineCount = lineCount + 1
                pageLineCount = pageLineCount + 1
                if pageLineCount == maxLine then
                    table.insert(pages, string.sub(txt, pageStart, cursor))
                    pageLineCount = 1
                    pageStart = cursor
                end
                if lineCount == lineCheck then
                    width = specifics[1].width
                    if specifics[2] then
                        lineCheck = specifics[2].lines 
                    end
                end
            end
            bigWord = 0
        elseif lineCursor + #i + 1 > maxChar + 1 then
            tempTextL = string.sub(txt, 1, cursor)
            tempTextR = string.sub(txt, cursor + 1)
            txt = ''
            txt = tempTextL..'\n'..tempTextR
            lineCount = lineCount + 1
            pageLineCount = pageLineCount + 1
            if pageLineCount == maxLine then
                table.insert(pages, string.sub(txt, pageStart, cursor))
                pageLineCount = 1
                pageStart = cursor
            end
            cursor = cursor + #i + 2
            lineCursor = #i + 1
            if lineCount == lineCheck then
                width = specifics[1].width
                if specifics[2] then
                    lineCheck = specifics[2].lines 
                end
            end
        else
            cursor = cursor + #i + 1
            if cursor >= nextBreak then
                if lineBreaks[1] then
                    nextBreak = table.remove(lineBreaks, 1)
                else
                    nextBreak = upperLimit
                end
                local returns = table.remove(returnCount, 1)       
                cursor = cursor + returns -1 
                lineCursor = #i + 1
                lineCount = lineCount + returns
                pageLineCount = pageLineCount + returns
            else
                lineCursor = lineCursor + #i + 1
            end
        end
    end
    if pages[1] then
        table.insert(pages, string.sub(txt, pageStart, cursor))
        return pages, lineCount
    else
        return txt,lineCount
    end
end

function textWrapSpecifics(rawText, char, pageHeight, specifics,chNum, errorFlag)
    local char = char or 10
    local width = specifics[1].width
    local bigWord = 0
    local cursor = 0
    local lineCursor = 0
    local tempTextL = ''
    local tempTextR = ''
    local lineCount = 1
    local pageLineCount = 1
    local pageStart = 0
    local pages = {}
    if errorFlag and errorFlag == 'error' then
        local bMarksEnd = {}
        table.insert(bMarksEnd, {line=1,char=1,y=1,x=1,lineHeight=1})
        --local eText = "\n\n\n\n     UTF-8 decoding error\n  Could not display CHAPTER "..chNum.."\n\nFor weblink to full text:\n[backspace] --> \"My folder\"\nScroll to book entry.\n[k] to open details page.\nLink is last item on left\n\n\nPage forward for next chapter"
        local eText = "\n\n\n\n     UTF-8 decoding error\n  Could not display CHAPTER "..chNum.."\n\n\nFull book available on Project\nGutenberg site: gutenberg.org\nFor weblink, press [5]\n\n\nPage forward for next chapter"
        table.insert(pages, {text=eText,bMarks=bMarksEnd})
        return pages, 1
    end
    if rawText == "THE END" then 
        local bMarksEnd = {}
        table.insert(bMarksEnd, {line=1,char=1,y=1,x=1,lineHeight=1})
        local page = "\n\n\n\n\n\n\n\n            THE END"
        table.insert(pages, {text=page,bMarks=bMarksEnd})
        return pages, 1
    end
    local tillEnd = 0
    local text = rawText:gsub(" +", " ")  
    local lineHeight = 22                                   
    local pageHeight = pageHeight or 490/600*DRAW_HEIGHT_ADJ
    local maxLine = math.floor(pageHeight/lineHeight)
    local maxChar = math.floor(width/char)
    local txtTemp = text:gsub('\n+', ' $$ ')
    local txt = '\n\n\n\n\n\n'..txtTemp
    pageLineCount = pageLineCount + 6
    cursor = cursor + 6
    local textCopy = txt
    local addSpace = false
    -- for passage markers
    local passageCharCount = 0
    local buffer = 100
    local upperBuffer = 100
    local passageMin = PREFS.size - buffer
    local passageMax = PREFS.size
    local bMarks = {}
    local bMarkCounter = 0
    for i in string.gmatch(textCopy, "%S+") do
        for l,spec in ipairs(specifics) do
            if pageLineCount <= spec.index then
                width = spec.width
                break
            end
        end
        maxChar = math.floor(width/char)
        if #i > maxChar then
            bigWord = #i
            while bigWord > maxChar do
                tillEnd = maxChar - lineCursor
                lineCount = lineCount + 1
                pageLineCount = pageLineCount + 1
                for l,spec in ipairs(specifics) do
                    if pageLineCount <= spec.index then
                        width = spec.width
                        break
                    end
                end
                bigWord = bigWord - tillEnd
                if bigWord > maxChar then
                    tempTextL = string.sub(txt, 1, cursor + tillEnd)
                    tempTextR = string.sub(txt, cursor + 1 + tillEnd)
                    cursor = cursor + tillEnd + 1
                    lineCursor = 1
                else
                    tempTextL = string.sub(txt, 1, cursor + 1 + tillEnd)
                    tempTextR = string.sub(txt, cursor + 2 + tillEnd)
                    cursor = cursor + tillEnd + 2 + bigWord
                    lineCursor = bigWord + 1
                end
                txt = ''
                txt = tempTextL..'\n'..tempTextR
                if pageLineCount == maxLine then
                    table.insert(pages, {text=string.sub(txt, pageStart, cursor),bMarks=bMarks})
                    bMarks = {}
                    pageLineCount = 1
                    pageStart = cursor
                end
            end
            bigWord = 0
        else
            for l,spec in ipairs(specifics) do
                if pageLineCount <= spec.index then
                    width = spec.width
                    break
                end
            end
            if i == '$$' then
                if pageLineCount == 1 then
                    tempTextL = string.sub(txt, 1, cursor)
                    tempTextR = string.sub(txt, cursor + 4)  
                    txt = ''
                    txt = tempTextL..tempTextR   
                    --pageLineCount = pageLineCount + 1
                else
                    tempTextL = string.sub(txt, 1, cursor)
                    tempTextR = string.sub(txt, cursor + 4)
                    txt = ''
                    txt = tempTextL..'\n\n'..tempTextR 
                    lineCount = lineCount + 2
                    pageLineCount = pageLineCount + 2
                    lineCursor = 0
                    cursor = cursor + 2
                end
                if passageCharCount >= passageMin then
                    table.insert(bMarks, {line=pageLineCount,char=lineCursor,y=(pageLineCount-1)*lineHeight,x=lineCursor*char,lineHeight=lineHeight})
                    bMarkCounter = bMarkCounter + 1
                    passageCharCount = 0
                end
                if pageLineCount >= maxLine then
                    local diff = pageLineCount - maxLine               
                    table.insert(pages, {text=string.sub(txt, pageStart, cursor),bMarks=bMarks})
                    if string.sub(txt,cursor, cursor) == '\n' then 
                        tempTextL = string.sub(txt, 1, cursor - 1)
                        tempTextR = string.sub(txt, cursor + 1)
                        txt = ''
                        txt = tempTextL..' '..tempTextR
                        --cursor = cursor + 1 
                    end
                    bMarks = {}
                    --cursor = cursor + 1
                    pageLineCount = 1
                    pageStart = cursor + 1    
                end
            elseif lineCursor + #i + 1 > maxChar + 1 then
                lineCount = lineCount + 1
                pageLineCount = pageLineCount + 1
                if addSpace then
                    tempTextL = string.sub(txt, 1, cursor - 1)
                    tempTextR = string.sub(txt, cursor - 1)
                    --print('page: '..(#pages+1)..'; first char of temptTextR is #'..string.sub(tempTextR,1,1)..'#')
                    --print('page: '..(#pages+1)..'; second char of temptTextR is #'..string.sub(tempTextR,2,2)..'#')
                    if string.sub(tempTextR,1,1) ~= ' ' then
                        local tempTextR2 = '  '..string.sub(tempTextR,3)
                        tempTextR = ''
                        tempTextR = tempTextR2
                    end
                    txt = ''
                    txt = tempTextL..' '..tempTextR
                    addSpace = false
                    cursor = cursor + 1            
                end
                if pageLineCount == maxLine then
                    table.insert(pages, {text=string.sub(txt, pageStart, cursor),bMarks=bMarks})
                    bMarks = {}
                    pageLineCount = 1
                    cursor = cursor           
                    addSpace = true
                    pageStart = cursor + 1        
                else
                    tempTextL = string.sub(txt, 1, cursor)
                    tempTextR = string.sub(txt, cursor + 1)
                    txt = ''
                    txt = tempTextL..'\n'..tempTextR
                end
                cursor = cursor + #i + 2
                lineCursor = #i + 1
                passageCharCount = passageCharCount + #i + 2
            else
                cursor = cursor + #i + 1
                lineCursor = lineCursor + #i + 1
                passageCharCount = passageCharCount + #i + 1
                if passageCharCount >= passageMax then
                    local a,z = string.find(i,'%l%l%l[%.!%?]"?')
                    if z then
                        table.insert(bMarks, {line=pageLineCount-1,char=lineCursor+z,y=(pageLineCount-1)*lineHeight,x=lineCursor*char,lineHeight=lineHeight})
                        bMarkCounter = bMarkCounter + 1
                        passageCharCount = 0                           
                    end
                end
            end
        end
    end
    if pages[1] then
        table.insert(pages, {text=string.sub(txt, pageStart, cursor),bMarks=bMarks})
        bMarks = {}
        return pages, bMarkCounter
    end
end

function getInfoButton(xMid,yMid,fontSize,color,modals,entries,func,func_param)
    local red = color[1]
    local blue = color[2]
    local green = color[3]
    local opacity_target = color[4] or 1
    local opacity = 0
    local x = xMid
    local y = yMid
    local font = FONT.courier
    if fontSize == 28 then
        font = FONT.courierXL
    end
    local text_x = x - (fontSize/4) - 1
    local button_y = y - (fontSize/2)
    local text_width = (x-text_x)*2
    local height = (y-button_y)*2
    local r_origin = fontSize/2
    local width = r_origin*2
    local button_x = x - width/2
    local r_pop = r_origin*1.2
    local r = 0
    local pressed = false
    local active = true
    local r_shrink = 0
    local letter = 'i'
    local handle = {}

    return {
        red = red,
        blue = blue,
        green = green,
        x = x,
        y = y,
        font = font,
        text_x = text_x,
        button_x = button_x,
        button_y = button_y,
        text_width = text_width,
        width = width,
        height = height,
        r_origin = r_origin,
        r_pop = r_pop,
        r = r,
        pressed = pressed,
        func = func,
        func_param = func_param,
        opacity = opacity,
        opacity_target = opacity_target,
        active = active,
        r_shrink = r_shrink,
        modals = modals,
        entries = entries,
        letter = letter,
        handle = handle,

        modalClick = function(self, mouse_x, mouse_y,options)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    if self.pressed then
                        self:onExit()
                    else
                        self:onEnter()
                    end
                    if self.entries and self.entries == 'explainer' then 
                        self:explainerOpen()
                    elseif self.func_param then
                        self.func(self.func_param)
                    else
                        self.func()
                    end
                end
            end
        end,

        onHover = function (self,dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if not self.pressed then
                    if my >= self.button_y and my <= self.button_y + self.height then
                        self:shrink()
                    else
                        self:unshrink()
                    end
                end
            else
                self:unshrink()
            end
        end,

        switchNav = function(self)

        end,

        shrink = function(self)
            self.r = self.r_shrink
        end,

        unshrink = function(self)
            Timer.tween(0.1,self,{r=self.r_origin})
        end,

        open = function(self)
            Timer.after(2,function()
                Timer.tween(0.5,self,{opacity=self.opacity_target},'in-quint')
                Timer.tween(1,self,{r=self.r_pop},'in-quint')
                Timer.after(1,function ()
                    Timer.tween(1,self,{r=self.r_origin},'in-quint')
                end)
            end)
        end,

        hide = function(self)
            Timer.tween(0.2,self,{opacity=0},'in-quint')
            self:deactivate()
        end,

        reappear = function(self,period,delay)
            local delay = delay or 2
            local period = period or 0.2
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity=self.opacity_target},'in-quint')
                self:activate()
            end)
        end,

        deactivate = function(self)
            self.active = false
        end,

        activate = function(self)
            self.active = true
        end,

        toSleep = function(self,flag)
        
        end,

        explainerOpen = function(self)
            local delay = 0.01
            if EXPLAINER and EXPLAINER.texts then
                return delay
            else
                EXPLAINER = explainIt()
                delay = EXPLAINER:open()
                self.handle = Timer.after(delay,function()
                    EXPLAINER = {}
                end)
            end
            return delay
        end,

        keyTest = function(self,key)

        end,

        onPress = function(self, key)
            if self.active then
                if key == 'i' then
                    if not self.pressed then
                        self.pressed = true
                        self.iLast = true
                        self:onEnter()
                        local keyNum = 8
                        if #self.modals > 6 then
                            keyNum = 9
                        end
                        INFO = infoBoard(150,125,400,400,500,keyNum)
                        INFO:open2()
                    elseif self.iLast then
                        self.pressed = false
                        self.iLast = false
                        if INFO then
                            self:onExit()
                            local delay = INFO:close2()
                            Timer.after(delay, function()
                                INFO = {}
                            end)
                        end
                    else
                        self.iLast = true
                        for _,v in ipairs(INFO.keys) do
                            v:glow(key,0.1)
                        end
                    end
                else
                    self.iLast = false
                end
            end
        end,

        onEnter = function(self)
            self.pressed = true
            local delay = 0.1
            Timer.tween(delay,self,{r=r_pop})
        end,

        onExit = function(self)
            self.pressed = false
            local delay = 0.1
            Timer.tween(delay,self,{r=r_origin})
        end,

        draw = function(self)
            love.graphics.setLineWidth(2)
            love.graphics.setColor(self.red,self.green,self.blue,self.opacity)
            love.graphics.circle('line',self.x,self.y,self.r)
            love.graphics.setFont(FONT.courier)
            love.graphics.print('i',self.text_x,self.button_y)
        end
    }

end

function navButton(xPos1,yPos1,width,height,color,font,index,modals,entries)
    local red = 1
    local green = 0
    local blue = 0
    local opacity_target = 1
    local leftBool = true
    local leftBoolMemory = true
    if color then
        red = color[1]
        green = color[2]
        blue = color[3]
        opacity_target = opacity_target or color[4]
    end
    local opacity = 0
    local bar_opacity = 0
    local bar_opacity_target = 0.5 
    local letter = ''
    local letters = {'u','i','o','j','k','l','space'}
    for i,v in ipairs(letters) do
        if i == index then
            letter = v
        end
    end
    local func = func
    local func_param = func_param
    local button_1_x = xPos1
    local button_1_y = yPos1
    local button_1_w = width
    local button_2_w = DRAW_WIDTH*0.2
    local button_2_x_l = button_1_x
    local button_2_x_r = button_1_x + button_1_w - button_2_w
    local button_2_x = button_2_x_l
    local button_2_y = button_1_y
    local text_x_l = button_1_x + width/2
    local text_x_r = button_1_y
    local text_x = text_x_l
    local text_y = button_1_y  
    local button_2_opacity = 0
    local button_2_opacity_target = 1
    local active = true

    return {
        letter = letter,
        font = font,
        red = red,
        blue = blue,
        green = green,
        red_bar = red,
        green_bar = green,
        blue_bar = blue,
        red_2 = 1,
        green_2 = 1,
        blue_2 = 1,
        red_button_2 = 1,
        green_button_2 = 1,
        blue_button_2 = 1,
        opacity = opacity,
        bar_opacity = bar_opacity,
        opacity_target = opacity_target,
        bar_opacity_target = bar_opacity_target,
        text = 'Nav',
        func = func,
        func_param = func_param,
        button_1_w = button_1_w,
        button_2_w = button_2_w,
        height = height,
        button_1_x = button_1_x,
        button_1_y = button_1_y,
        button_2_x = button_2_x,
        button_2_y = button_2_y,
        button_2_x_l = button_2_x_l,
        button_2_x_r = button_2_x_r,
        index = index,
        text_x = text_x,
        text_x_l = text_x_l,
        text_x_r = text_x_r,
        text_y = text_y,
        leftBool = leftBool,
        leftBoolMemory = leftBoolMemory,
        button_2_opacity = button_2_opacity,
        button_2_opacity_target = button_2_opacity_target,
        active = active,
        color = color,
        modals = modals,
        entries = entries,

        modalClick = function(self, mouse_x, mouse_y)
            if (mouse_x >= self.button_1_x) and (mouse_x <= self.button_1_x + self.button_1_w) then
                if (mouse_y >= self.button_1_y) and (mouse_y <= self.button_1_y + self.height) then
                    self:onPress(self.letter)
                end
            end
        end,

        onHover = function (self,dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if self.active then
                if mx >= self.button_1_x and mx <= self.button_1_x + self.button_1_w then
                    if my >= self.button_1_y and my <= self.button_1_y + self.height then
                        self:goLight()
                    else
                        self:goDark()
                    end
                end
            end
        end,

        goLight = function(self,info)
            self.red_bar = 1
            self.green_bar = 1
            self.blue_bar = 1
            self.red_2 = self.color[1]
            self.green_2 = self.color[2]
            self.blue_2 = self.color[3]
            self.button_2_opacity = self.bar_opacity
            if info then
                Timer.after(0.2, function()
                    self:goDark()
                end)
            end
        end,

        goDark = function(self)
            self.red_bar = self.color[1]
            self.green_bar = self.color[2]
            self.blue_bar = self.color[3]
            self.red_2 = 1
            self.green_2 = 1
            self.blue_2 = 1
            self.button_2_opacity = 1
        end,


        toSleep = function(self,flag)
        
        end,

        onEnter = function(self)

        end,
        deactivate = function(self)
            self.active = false
            self.leftBoolMemory = self.leftBool 
        end,

        activate = function(self)
            local delay = 0.01
            if self.leftBool ~= self.leftBoolMemory then
                delay = self:buttonPressed(0.5)
            end
            Timer.after(delay, function ()
                self.active = true
            end)
        end,

        keyTest = function(self,key)
            if key == 'i' then
                if not self.keyTestBool then
                    self.keyTestBool = true
                    self.iLast = true
                    self:deactivate()
                    return
                elseif self.keyTestBool and self.iLast then
                    self.keyTestBool = false
                    self.iLast = false
                    self:activate()
                    return
                else
                    self.iLast = true
                end
            elseif self.keyTestBool and key == self.letter then
                self.iLast = false
                self:buttonPressed(0.5)
                for _,v in ipairs(INFO.keys) do
                    v:glow(key,0.1)
                    self:goLight('info')
                end
            else
                self.iLast = false
            end
        end,

        buttonPressed = function(self,delay)
            delay = delay or 1
            if self.leftBool then
                Timer.tween(delay,self,{button_2_x=self.button_2_x_r},'in-out-cubic')
                self.leftBool = false
            else
                Timer.tween(delay,self,{button_2_x=self.button_2_x_l},'in-out-cubic')
                self.leftBool = true
            end
            return 1
        end,

        onPress = function(self,key)
            if self.active then
                if key == self.letter then
                    self.active = false
                    local delay = self:buttonPressed()
                    Timer.after(delay,function()
                        self.active = true
                    end)
                    for _,v in ipairs(self.modals) do
                        v:switchNav()
                    end
                end
            end
        end,

        switchNav = function(self)

        end,

        open = function(self)
            local delay = 0.5
            Timer.after(0.5,function()
                Timer.tween(delay,self,{opacity=self.opacity_target}, 'in-quint')
                Timer.tween(delay,self,{button_2_opacity=self.button_2_opacity_target}, 'in-quint')
                Timer.tween(delay,self,{bar_opacity=self.bar_opacity_target}, 'in-quint')
            end)
        end,

        hide = function(self,period,delay)
            local period = period or 0.2
            local delay = delay or 0.01
            Timer.after(delay,function ()            
                Timer.tween(period,self,{opacity=0}, 'in-quint')
                Timer.tween(period,self,{button_2_opacity=0}, 'in-quint')
                Timer.tween(period,self,{bar_opacity=0}, 'in-quint')
                self:deactivate()
            end)
            return period + delay
        end,

        reappear = function(self,period,delay)
            local period = period or 0.5
            local delay = delay or 0.5
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity=self.opacity_target}, 'in-quint')
                Timer.tween(period,self,{button_2_opacity=self.button_2_opacity_target}, 'in-quint')
                Timer.tween(period,self,{bar_opacity=self.bar_opacity_target}, 'in-quint')
                self:activate()
            end)
        end,

        draw = function(self)
            love.graphics.setColor(self.red_bar,self.green_bar,self.blue_bar,self.bar_opacity)
            love.graphics.rectangle('fill', self.button_1_x, self.button_1_y, self.button_1_w, self.height,10,10)
            love.graphics.setColor(self.red_2,self.green_2,self.blue_2,self.button_2_opacity)
            love.graphics.rectangle('fill', self.button_2_x, self.button_2_y, self.button_2_w, self.height,10,10)
            love.graphics.setColor(self.red_bar,self.green_bar,self.blue_bar,self.opacity)
            love.graphics.printf(self.text,self.font,self.button_2_x,self.button_1_y,self.button_2_w,'center')
            love.graphics.setColor(self.red,self.green,self.blue,self.opacity)
            love.graphics.rectangle('line', self.button_1_x, self.button_1_y, self.button_1_w, self.height,10,10)
        end
    }
end

function getButton(textSet,func, func_param, xPos, yPos, width, height,color,fontSet,fontIn,index,modals,entries)
    local lines = #textSet
    local info = false
    if textSet[1] == 'i' then
        info = true
    end
    local red = 1
    local green = 0
    local blue = 0
    local opacity_target = 1
    if color then
        red = color[1]
        green = color[2]
        blue = color[3]
        opacity_target = opacity_target or color[4]
    end
    local opacity = 0
    local func = func
    local fontSet = fontSet
    local font = {}
    for _,v in ipairs(fontIn) do
        table.insert(font, v)
    end
    local letter = ''
    local letters = {'u','i','o','j','k','l','space','return'}
    for i,v in ipairs(letters) do
        if i == index then
            letter = v
        end
    end
    local info_atScale = 300
    local info_scale_origin = 0
    local info_scale_pop = 0.25
    local info_scale_target = 0.2
    local info_scale = info_scale_origin
    local info_x_origin = xPos + width/2
    local info_y_origin = yPos + height/2
    local info_x_pop = info_x_origin - (info_atScale*info_scale_pop)/2
    local info_y_pop = info_y_origin - (info_atScale*info_scale_pop)/2
    local info_x_target = info_x_origin - (info_atScale*info_scale_target)/2
    local info_y_target = info_y_origin - (info_atScale*info_scale_target)/2
    local info_opacity_origin = 1
    local info_opacity_target = 1
    local info_opacity = info_opacity_origin
    local info_x = info_x_origin
    local info_y = info_y_origin
    local font_opacity = 0
    local font_opacity_target = 1
    local info_on = false
    local icon_x = 0
    local icon_y = 0
    icon_x = xPos - fontSet[1]/2
    icon_y = yPos - fontSet[1]/2
    local active = true
    local sleep = false
    local sleepFlag = 'none'
    if func == scrollUp then
        sleepFlag = 'first'
        sleep = true
    elseif func == scrollDown then
        sleepFlag = 'last'
    elseif func == selectThis then
        sleepFlag = 'empty'
    end
    local keyTestBool = false
    local navSwitch = false
    local entry
    if entries then
        entry = entries[1]
    end
    local iLast = false

    return {
        letter = letter,
        origin_width = width,
        origin_height = height,
        origin_button_x = xPos,
        origin_button_y = yPos,
        font = font,
        lines = lines,
        fontSet = fontSet,
        red = red,
        blue = blue,
        green = green,
        red_line = red,
        blue_line = blue,
        green_line = green,
        red_text = 1,
        green_text = 1,
        blue_text = 1,
        opacity = opacity,
        opacity_line = opacity,
        opacity_target = opacity_target,
        textSet = textSet,
        func = func,
        func_param = func_param,
        width = width,
        height = height,
        button_x = xPos,
        button_y = yPos,
        index = index,
        info_x = info_x,
        info_y = info_y,
        info_x_target = info_x_target,
        info_y_target = info_y_target,
        info_x_origin = info_x_origin,
        info_y_origin = info_y_origin,
        info_x_pop = info_x_pop,
        info_y_pop = info_y_pop,
        info_scale = info_scale,
        info_scale_origin = info_scale_origin,
        info_scale_target = info_scale_target,
        info_scale_pop = info_scale_pop,
        font_opacity = font_opacity,
        font_opacity_target = font_opacity_target,
        info_on = info_on,
        info = info,
        icon_x = icon_x,
        icon_y = icon_y,
        info_opacity = info_opacity,
        info_opacity_origin = info_opacity_origin,
        info_opacity_target = info_opacity_target,
        active = active,
        sleepFlag = sleepFlag,
        sleep = sleep,
        keyTestBool = keyTestBool,
        color = color,
        modals = modals,
        entries = entries,
        entry = entry,
        navSwitch = navSwitch,
        iLast = iLast,

        modalClick = function(self, mouse_x, mouse_y,options)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    if self.active then
                        self:onPress(self.letter)
                        if self.letter == 'i' then
                            for _,v in ipairs(self.modals) do
                                v:keyTest('i')
                            end
                        end
                    end
                end
            end
        end,

        onHover = function (self,dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_x and mx <= self.button_x + self.width then
                if self.active then
                    if my >= self.button_y and my <= self.button_y + self.height then
                        self:goLight()
                    else
                        self:goDark()
                    end
                end
            elseif self.active then
                self:goDark()
            end
        end,

        goLight = function(self,info)
            self.red = 1
            self.green = 1
            self.blue = 1
            self.red_text = self.color[1]
            self.green_text = self.color[2]
            self.blue_text = self.color[3]
            self.opacity_line = 1
            if info then
                Timer.after(0.2, function()
                    self:goDark()
                end)
            end
        end,

        goDark = function(self)
            self.opacity_line = 0
            self.red = self.color[1]
            self.green = self.color[2]
            self.blue = self.color[3]
            self.red_text = 1
            self.green_text = 1
            self.blue_text = 1
        end,

        onEnter = function(self, key,options)
            if key == self.letter then
                if self.entry then
                    self.func(self.entry)
                elseif self.func_param then
                    self.func(self.func_param)
                end
            end
        end,

        hide = function(self,period,delay)
            local period = period or 0.2
            local delay = delay or 0.01
            Timer.after(delay,function ()
                Timer.tween(period,self,{opacity=0},'in-quint')
                Timer.tween(period,self,{font_opacity=0},'in-quint')
                self:deactivate()
            end)
            return period + delay
        end,

        open = function(self)
            local delay = 0.5
            Timer.after(0.5,function()
                Timer.tween(delay,self,{opacity=self.opacity_target},'in-quint')
                Timer.tween(delay,self,{font_opacity=self.font_opacity_target},'in-quint', function()
                    if self.sleep then
                        Timer.tween(delay,self,{opacity=0.3})
                        Timer.tween(delay,self,{font_opacity=0.3})
                        self:deactivate()
                    end
                end)
            end)
        end,

        reappear = function(self,period,delay)
            local period = period or 0.5
            local delay = delay or 0.5
            Timer.after(delay,function()
                Timer.tween(period,self,{opacity=self.opacity_target},'in-quint')
                Timer.tween(period,self,{font_opacity=self.font_opacity_target},'in-quint')
                self:activate()
            end)
        end,

        toSleep = function(self,flag)
            if flag == self.sleepFlag then
                self:deactivate()
                self.opacity=0.3
                self.font_opacity=0.3 
                self.sleep = true
            elseif self.sleep then
                self:activate()
                self.opacity=self.opacity_target
                self.font_opacity=self.font_opacity_target
                self.sleep = false
            end
        end,

        deactivate = function(self)
            self.active = false
        end,

        activate = function(self)
            self.active = true
            Timer.tween(0.2,self,{opacity=1})
            Timer.tween(0.2,self,{font_opacity=1})
        end,


        keyTest = function(self,key)
            --print('keyTest arrived 1       key:',self.letter)
            if key == 'i' then
                --print('keyTest arrived 2       key:',self.letter)
                if not self.keyTestBool then
                    --print('keyTest arrived 3       key:',self.letter)
                    self.keyTestBool = true
                    self.iLast = true
                    if self.letter ~= 'i' then
                        --print('keyTest arrived 4       key:',self.letter)
                        self:deactivate()
                        return
                    else
                        --print('keyTest arrived 5       key:',self.letter)
                        self.info_on = true
                        self:onPressInfo()
                    end
                elseif self.keyTestBool and self.iLast then
                    --print('keyTest arrived 6       key:',self.letter)
                    self.keyTestBool = false
                    self.iLast = false
                    if self.letter ~= 'i' then
                        --print('keyTest arrived 7       key:',self.letter)
                        self:activate()
                        return
                    else
                        --print('keyTest arrived 8       key:',self.letter)
                        self:activate()
                        if INFO and INFO.close then
                            --print('keyTest arrived 9       key:',self.letter)
                            local delay = INFO:close()
                            infoBool = false
                            self.info_on = false
                            self:onExitInfo()
                            Timer.after(delay, function()
                                INFO = {}
                            end)
                        end
                        Timer.after(0.1, function()
                            Timer.tween(0.1,self,{button_x=self.origin_button_x},mode)
                            Timer.tween(0.1,self,{button_y=self.origin_button_y},mode)
                            Timer.tween(0.1,self,{width=self.origin_width},mode)
                            Timer.tween(0.1,self,{height=self.origin_height},mode)
                        end)
                    end
                else
                    --print('keyTest arrived 10       key:',self.letter)
                    self:buttonPressed()
                    self:buttonReleased()
                    if INFO and INFO.keys then
                        --print('keyTest arrived 11       key:',self.letter)
                        for _,v in ipairs(INFO.keys) do
                            v:glow(key,0.1)
                            self:goLight('info')
                        end
                    end
                end
            elseif self.keyTestBool and key == self.letter then
                --print('keyTest arrived 12       key:',self.letter)
                self:buttonPressed()
                self:buttonReleased()
                if INFO and INFO.keys then 
                    for _,v in ipairs(INFO.keys) do
                        v:glow(key,0.1)
                        self:goLight('info')
                    end
                end
            end
            if key == 'i' then
                --print('keyTest arrived 13       key:',self.letter)
                self.iLast = true
            elseif self.keyTestBool and key ~= 'i' then
                --print('keyTest arrived 14       key:',self.letter)
                self.iLast = false
            end
        end,

        onPress = function(self,key)
            --self.active = true
            if self.active then
                if key == self.letter then
                    if self.func_param then
                        if self.func_param ~= 'params' then
                            if self.func == infoWindowManager then
                                self.func(self.func_param)
                            else
                                self.func(self.func_param)
                            end
                        else
                            if self.navSwitch then
                                readerNav(self.entry,self.modals,key)
                            else 
                                self.func(self.entry,self.modals,key)
                            end
                        end
                    end
                    local mode = 'in-quad'
                    local shrinkFactor = 0.95
                    local newWidth = self.width*shrinkFactor
                    local newHeight = self.height*shrinkFactor
                    self.button_x = self.origin_button_x + (self.origin_width - newWidth)/2
                    self.button_y = self.origin_button_y + (self.origin_height - newHeight)/2
                    self.width = newWidth
                    self.height = newHeight
                    self:buttonReleased()
                end
            end
        end,

        switchNav = function(self)
            if self.entries then
                if #self.entries > 1 then
                    if self.navSwitch then
                        self.entry = self.entries[1]
                        self.navSwitch = false
                    else
                        self.entry = self.entries[2]
                        self.navSwitch = true
                    end
                end
            end
        end,

        buttonPressed = function(self)
            local shrinkFactor = 0.95
            local newWidth = self.width*shrinkFactor
            local newHeight = self.height*shrinkFactor
            self.button_x = self.origin_button_x + (self.origin_width - newWidth)/2
            self.button_y = self.origin_button_y + (self.origin_height - newHeight)/2
            self.width = newWidth
            self.height = newHeight
        end,

        buttonReleased = function(self)
            local mode = 'in-quad'
            Timer.tween(0.2,self,{button_x=self.origin_button_x},mode)
            Timer.tween(0.2,self,{button_y=self.origin_button_y},mode)
            Timer.tween(0.2,self,{width=self.origin_width},mode)
            Timer.tween(0.2,self,{height=self.origin_height},mode)
        end,


        onPressInfo = function(self)
            INFO = infoBoard(150,125,400,400,500)
            INFO:open()
            local delay1 = 0.2
            local delay2 = 0.1
            Timer.tween(0.1,self,{font_opacity=0})
            Timer.tween(delay1+delay2,self,{info_opacity=1})
            Timer.tween(delay1,self,{info_x=self.info_x_pop})
            Timer.tween(delay1,self,{info_y=self.info_y_pop})
            Timer.tween(delay1,self,{info_scale=self.info_scale_pop})
            Timer.after(delay1, function()
                Timer.tween(delay2,self,{info_x=self.info_x_target})    
                Timer.tween(delay2,self,{info_y=self.info_y_target})    
                Timer.tween(delay2,self,{info_scale=self.info_scale_target})             
            end)
        end,

        onExitInfo = function(self)
            local mode = 'in-quad'
            local delay1 = 0.1
            local delay2 = 0.2
            Timer.tween(delay1+delay2,self,{info_opacity=0})
            Timer.tween(delay1,self,{info_x=self.info_x_pop})
            Timer.tween(delay1,self,{info_y=self.info_y_pop})
            Timer.tween(delay1,self,{info_scale=self.info_scale_pop})
            Timer.after(delay1, function()
                Timer.tween(delay2,self,{info_x=self.info_x_origin})    
                Timer.tween(delay2,self,{info_y=self.info_y_origin})    
                Timer.tween(delay2,self,{info_scale=self.info_scale_origin})
                Timer.tween(delay2,self,{font_opacity=1})
                Timer.after(0.1, function()
                    Timer.tween(0.1,self,{button_x=self.origin_button_x},mode)
                    Timer.tween(0.1,self,{button_y=self.origin_button_y},mode)
                    Timer.tween(0.1,self,{width=self.origin_width},mode)
                    Timer.tween(0.1,self,{height=self.origin_height},mode)
                    self.info_on = false
                end)        
            end)
        end,

        draw = function(self)
            love.graphics.setColor(self.red,self.green,self.blue,self.opacity)
            love.graphics.rectangle('fill', self.button_x, self.button_y, self.width, self.height,10,10)
            love.graphics.setLineWidth(5)
            love.graphics.setColor(self.red_line,self.green_line,self.blue_line,self.opacity_line)
            love.graphics.rectangle('line', self.button_x, self.button_y, self.width, self.height,10,10)
            if self.info then
                love.graphics.setColor(214/255,26/255,60/255,self.info_opacity)
                love.graphics.draw(ICONS.info, self.info_x,self.info_y,nil,self.info_scale)
            end
            love.graphics.setColor(self.red_text,self.green_text,self.blue_text,self.font_opacity)
            if type(self.textSet[1]) == "string" then
                for i,v in ipairs(self.textSet) do
                    if v ~= '' then
                        love.graphics.printf(v,self.font[i],self.button_x,((self.height/self.lines)*i-self.fontSet[i])/2+self.button_y,self.width,'center')
                    end
                end
            else
                love.graphics.setColor(self.red_text,self.green_text,self.blue_text,self.font_opacity)
                love.graphics.draw(textSet[1],self.icon_x+(self.width/2),self.icon_y+(self.height/2))
            end
        end
    }
end