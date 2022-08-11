FRANZEGRAMVAR = {}

function infoHalt(modals)
    for _,v in ipairs(modals) do
        v:infoHalt(state)
    end
end

function closeInfoWindows(params)
    local delay = 0
    local totalDelay = 0
    for i,v in ipairs(INFOWINDOWS) do
        v:close()
    end
    Timer.after(0.2,function()
        INFOWINDOWS = {}
    end)
end

function infoWindowManager(params)
    if INFOWINDOWS and INFOWINDOWS[1] then
        for _,v in ipairs(INFOWINDOWS) do
            if v.infoWindowButtons then
                for _,w in ipairs(v.infoWindowButtons) do
                    if v.deactivate then
                        v:deactivate()
                    end
                end
            end
            if v.printVanish then
                v:printVanish()
            end
        end
        table.insert(INFOWINDOWS, getInfoWindow(params))
        for _,v in ipairs(INFOWINDOWS[#INFOWINDOWS].infoWindowButtons) do
            v:open()
        end
        INFOWINDOWS[#INFOWINDOWS]:open()
    else
        INFOWINDOWS = {}
        table.insert(INFOWINDOWS, getInfoWindow(params))
        for _,v in ipairs(INFOWINDOWS[#INFOWINDOWS].infoWindowButtons) do
            v:open()
        end
        INFOWINDOWS[#INFOWINDOWS]:open()
    end
end

function getGif(text)
    local pathToSaveFolder = love.filesystem.getSaveDirectory()
    if pathToSaveFolder..'/userGifNew.gif' then
        os.rename(pathToSaveFolder..'/userGifNew.gif', pathToSaveFolder..'/userGifOld.gif')
    end
    local pathAdj = '"'..pathToSaveFolder..'"'
    local textAdj = text:gsub('"', '\\'..'"')
    local textAdj2 = textAdj:gsub('"', '\\'.."'")
    local textAdj4 = textAdj2:match'^%s*(.*)'
    local textAdj4x = '"'..textAdj4..'"'
    local path = love.filesystem.getSaveDirectory()
    local handle = io.popen('python3 '..bashEscape(path).. '/venv/gifMaker.py '..textAdj4x..' '..pathAdj) 
    local result = handle:read("*a")
    handle:close()
    for _,v in ipairs(INFOWINDOWS[#INFOWINDOWS].infoWindowButtons) do
        v:deactivate()
    end
    infoWindowManager({text,{{"open Gif ('k')", 'k'},{"go to save\nfolder ('o')",'o'},{"close/exit ('u')",'u'}},DRAW_WIDTH*0.1+DRAW_WIDTH*0.125/2,DRAW_HEIGHT*0.9+DRAW_HEIGHT*0.1/2,{openGif,gotoSaveFolder,closeInfoWindows},{pathAdj,'params'},'left'})
end

function gotoSaveFolder(params)
    love.system.openURL("file://"..love.filesystem.getSaveDirectory())
end

function openGif(params)
    if pcall(doPopen2,params) then
        print('command sent via doPopen')
    else
        print('*****************doPopen failed*********************')
    end
end

function doPopen2(path)
    local pathToSaveFolder = love.filesystem.getSaveDirectory()..'/userGifNew.gif'
    local path2 = love.filesystem.getSource( )
    local handle = io.popen('love '..bashEscape(path2)..'/vgif.love '..bashEscape(pathToSaveFolder))
    local result = handle:read("*a")
    handle:close()
end


function textSeenPageMap(textSeen)
    local index
    local cursor
    local len
    local textLen
    local linesMapped = {}
    local pagesMapped = {}
    local lineNum = 0
    for i,v in ipairs(textSeen) do
        index = 0
        cursor = 1
        len = 0
        textLen = #v.text
        lineNum = 1
        while true do
            index = string.find(v.text, '\n', index + 1)
            if index then
                len = index - cursor
                table.insert(linesMapped, {index=cursor,len=len})
                cursor = index
                lineNum = lineNum + 1
                if index >= textLen then
                    break
                end
            else
                len = textLen - cursor
                table.insert(linesMapped,{index=cursor,len=len})
                break 
            end
        end
        table.insert(pagesMapped, linesMapped)
        linesMapped = {}
    end
    return pagesMapped
end

function franzegram(textSeen)
    local pagesMapped = textSeenPageMap(textSeen)
    local char = 14
    local line = 27
    local text = {}
    for i,v in ipairs(textSeen) do
        table.insert(text, v.text)
    end
    local start_x = textSeen[1].x
    local start_y = textSeen[1].y - line
    local pages = #textSeen
    local page = 1
    local selectText = ''
    local selectTempText = ''
    local color = {0,1,0,0.3}
    local cursor = false
    local select = false
    local active = true
    local minimize = true
    local firstNewLine = true
    local forward = true
    local gate_l = true
    local gate_j = true
    local next = true
    local lineCursor = 1
    local lines = {}
    local lineCounter = 1
    local charIndex = 0
    local charIndexStart = 0
    local charIndexEnd = 0
    local pageCursor = 1
    local maxLine = 15
    local linesSave = {}
    local charsSave = {}
    local franzeWindows = {
        {"Find your selection:\n\n--'j' & 'l' to page -/+\n\nWhen you see your selection:\n\n--'space' to drop cursor on page",{{"page - ('j')",'j'},{"page + ('l')",'l'},{"cursor ('space')",'space'},{"close/exit ('u')",'u'}},DRAW_WIDTH*0.1+DRAW_WIDTH*0.125/2,DRAW_HEIGHT*0.9+DRAW_HEIGHT*0.1/2,{'franzeVar','franzeVar','franzeVar',closeInfoWindows},{'j','l','k','params'},'left'},      
        {"Move cursor to start of your selection by pressing 'j' & 'l' keys\n\nThen press 'k' to set selection start",{{"cursor - ('j')",'j'},{"cursor + ('l')",'l'},{"set cursor ('k')",'k'},{"close/exit ('u')",'u'}},DRAW_WIDTH*0.1+DRAW_WIDTH*0.125/2,DRAW_HEIGHT*0.9+DRAW_HEIGHT*0.1/2,{'franzeVar','franzeVar','franzeVar',closeInfoWindows},{'j','l','k','params'},'left'},                   
        {"Move cursor to end of selection with 'j' & 'l'\n\nThen press 'space' to set\n\nYour selection:\n\n\n\n",{{"cursor - ('j')",'j'},{"cursor + ('l')",'l'},{"select ('space')",'space'},{"close/exit ('u')",'u'}},DRAW_WIDTH*0.1+DRAW_WIDTH*0.125/2,DRAW_HEIGHT*0.9+DRAW_HEIGHT*0.1/2,{'franzeVar','franzeVar',getGif,closeInfoWindows},{'j','l','getGif','params'},'left'}                   
    }
    infoWindowManager(franzeWindows[1])
    return {
        char = char,
        start_x = start_x,
        start_y = start_y,
        pages = pages,
        color = color,
        cursor = cursor,
        active = active,
        lines = lines,
        line = line,
        select = select,
        charIndexStart = charIndexStart,
        charIndexEnd = charIndexEnd,
        charIndex = charIndex,
        franzeWindows = franzeWindows,
        text = text,
        page = page,
        pageCursor = pageCursor,
        linesSave = linesSave,
        charsSave = charsSave,
        lineCounter = lineCounter,
        pagesMapped = pagesMapped,
        textSeen = textSeen,
        selectText = selectText,
        selectTempText = selectTempText,
        forward = forward,
        next = next,
        firstNewLine = firstNewLine,
        lineCursor = lineCursor,
        minimize = minimize,
        gate_j = gate_j,
        gate_l = gate_l,

        getCurrentPage = function(self)
            self.lineCounter = 1
            for i,v in ipairs(self.textSeen) do
                if v.cursor then
                    return i
                end
            end
        end,

        pageForward = function(self,select)
            if self.page < self.pages then
                if select == 'select' then
                    self:storeIt()
                end
                self.lineCounter = 1
                self.page = self.page + 1
                local next = false
                for i,v in ipairs(self.textSeen) do
                    if next then
                        v.cursor = true
                        v:scrollOn()
                        next = false
                    elseif v.cursor then
                        next = true
                        v.cursor = false
                        v:scrollOff()
                    else
                        v:scrollOff()
                    end
                end
            end
        end,

        storeIt = function(self)
            if self.linesSave and self.linesSave[1] and self.linesSave[1].x then
                self.lines = {}
                table.insert(self.lines, self.linesSave)
                self.linesSave = {}
                return 'fromStorage'
            else
                table.insert(self.linesSave, self.lines)
                self.lines = {}
            end
            local txt = ''
            if self.charIndexEnd - self.charIndexStart > 0 then
                txt = string.sub(self.text[self.page], self.charIndexEnd,self.charIndexStart)
            else
                txt = string.sub(self.text[self.page], self.charIndexStart,self.charIndexEnd)
            end
            self.charsSave = {page=self.page,text=txt,charStart=self.charIndexStart,charEnd= self.charIndexEnd}
            return 'toStorage'
        end,

        pageBack = function(self,select)
            if self.page > 1 then
                if select == 'select' then
                    self:storeIt()
                end
                self.page = self.page - 1 
                self.lineCounter = #self.pagesMapped[self.page]
                local next = false
                for i=#self.textSeen, 1, -1 do
                    if next then
                        self.textSeen[i].cursor = true
                        self.textSeen[i]:scrollOn()
                        next = false
                    elseif self.textSeen[i].cursor then
                        next = true
                        self.textSeen[i].cursor = false
                        self.textSeen[i]:scrollOff()
                    end
                end
            end
        end,

        makeSelectText = function(self,key,char)
            self.minimize = false
            if #self.selectText == 1 then
                if key == 'l' then
                    self.forward = true
                elseif key == 'j' then
                    self.forward = false
                end
            end
            if key == 'k' then
                self.selectTempText = self.selectText..char
                self.selectText = ''
                self.selectText = self.selectTempText
                self.selectTempText = ''
            end
            if self.forward then
                if key == 'l' then
                    self.minimize = false
                else
                    self.minimize = true
                end
            else
                if key == 'j' then
                    self.minimize = true
                else
                    self.minimize = false
                end
            end
            if #self.selectText < 300 or minimize then
                if char == '\n' then
                    char = ''
                end
                if key == 'l' then
                    if self.forward then
                        self.selectTempText = self.selectText..char             --self.text[self.page]:sub(self.charIndex+1,self.charIndex+1)
                        self.selectText = ''
                        self.selectText = self.selectTempText
                        self.selectTempText = ''  
                    else
                        self.selectTempText = self.selectText:sub(2)
                        self.selectText = ''
                        self.selectText = self.selectTempText
                        self.selectTempText = '' 
                    end
                elseif key == 'j' then
                    if self.forward then
                        self.selectTempText = self.selectText:sub(1,-2)
                        self.selectText = ''
                        self.selectText = self.selectTempText
                        self.selectTempText = ''  
                    else
                        self.selectTempText = char..self.selectText             --self.text[self.page]:sub(self.charIndex+1,self.charIndex+1)..self.selectText
                        self.selectText = ''
                        self.selectText = self.selectTempText
                        self.selectTempText = '' 
                    end
                end
                INFOWINDOWS[4]:getSelectText(self.selectText)
            end
        end,

        onPress = function(self,key,signature)
            if #self.selectText >= 300 then
                if self.forward then
                    self.gate_l = false
                else
                    self.gate_j = false
                end
            else
                self.gate_j = true
                self.gate_l = true
            end
            if key == 'k' or key == 'space' then
                if not self.active then
                    self.active = true
                    self.page = self:getCurrentPage()
                elseif not self.cursor then
                    self.cursor = true
                    self.lines = {}
                    self.charIndex = 1
                    self.page = self:getCurrentPage()
                    table.insert(self.lines, {x=self.start_x,y=self.start_y+self.lineCounter*self.line,w=self.char})
                    for _,v in ipairs(INFOWINDOWS[2].infoWindowButtons) do
                        v:deactivate()
                    end
                    infoWindowManager(self.franzeWindows[2])
                elseif not self.select then
                    self.select = true
                    self.charIndexStart = self.charIndex
                    INFOWINDOWS[3]:close()
                    infoWindowManager(self.franzeWindows[3])
                    if self.lineCounter == 1 then
                        self:makeSelectText(key,self.text[self.page]:sub(self.pageCursor,self.pageCursor))
                    else
                        self:makeSelectText(key,self.text[self.page]:sub(self.pageCursor,self.pageCursor))
                    end
                else
                    self.charIndexEnd = self.charIndexEnd
                end
            elseif key == 'l' then
                if self.active and self. gate_l then
                    if not self.cursor then
                        self:pageForward()
                    elseif not self.select then
                        if self.pageCursor + 1 >= #self.text[self.page] then
                            self:pageForward()
                            self.pageCursor = 1
                            self.lines[1].x = self.start_x
                            self.lines[1].y = self.start_y+self.lineCounter*self.line
                        end
                        if self.lineCursor > self.pagesMapped[self.page][self.lineCounter].len then
                            self.lineCounter = self.lineCounter + 1
                            self.lines[1].x = self.start_x
                            self.lines[1].y = self.lines[1].y + self.line
                            self.lineCursor = 1
                        else
                            self.lines[1].x = self.lines[1].x + self.char
                            self.lineCursor = self.lineCursor + 1
                            self.charIndex = self.charIndex+1
                            self.pageCursor = self.pageCursor + 1
                        end
                    else
                        if self.lineCursor > self.pagesMapped[self.page][self.lineCounter].len then
                            if self.lineCounter == #self.pagesMapped[self.page] then
                                self:pageForward('select')
                                self.pageCursor = 0
                                local storage = self:storeIt()
                                if storage == 'toStorage' then
                                    table.insert(self.lines, {x=self.start_x,y=self.start_y+self.lineCounter*self.line,w=self.char})
                                end
                                self.lineCursor = 1
                            else
                                self.lineCounter = self.lineCounter + 1
                                if self.forward then
                                    table.insert(self.lines, {x=self.start_x,y=self.lines[#self.lines].y+self.line,w=self.char})
                                else
                                    table.remove(self.lines, #self.lines)
                                end

                                self.lineCursor = 1
                            end
                        else
                            self:makeSelectText(key,self.text[self.page]:sub(self.pageCursor+1,self.pageCursor+1))
                            if self.forward then
                                self.lines[#self.lines].w = self.lines[#self.lines].w + self.char
                            else
                                self.lines[#self.lines].w = self.lines[#self.lines].w - self.char
                                self.lines[#self.lines].x = self.lines[#self.lines].x + self.char
                            end
                            self.pageCursor = self.pageCursor + 1
                            self.charIndex = self.charIndex + 1
                            self.lineCursor = self.lineCursor + 1
                        end
                    end
                end
            elseif key == 'j' then
                if self.active and self.gate_j then
                    if not self.cursor then
                        self:pageBack()
                    elseif not self.select then
                        if self.pageCursor <= 1 then
                            self:pageBack()
                            self.pageCursor = #self.text[self.page]
                            self.lines[1].x=self.start_x +self.pagesMapped[self.page][self.lineCounter].len*char
                            self.lines[1].y=self.start_y+self.line*self.lineCounter
                        end
                        if self.lineCursor < 1 then
                            self.lineCounter = self.lineCounter - 1
                            self.lines[1].x = self.start_x + self.pagesMapped[self.page][self.lineCounter].len*self.char
                            self.lines[1].y = self.lines[1].y - self.line
                            self.lineCursor = self.pagesMapped[self.page][self.lineCounter].len 
                        else
                            self.lines[1].x = self.lines[1].x - self.char
                            self.lineCursor = self.lineCursor - 1
                            self.charIndex = self.charIndex - 1
                            self.pageCursor = self.pageCursor - 1
                        end
                    else
                        if self.lineCursor < 1 then
                            if self.lineCounter == 1 then
                                self:pageBack('select')
                                self.pageCursor = #self.text[self.page]
                                local storage = self:storeIt()
                                if storage == 'toStorage' then
                                    table.insert(self.lines, {x=self.start_x + self.pagesMapped[self.page][self.lineCounter].len*self.char,y=self.start_y+self.line*self.lineCounter,w=self.char})    
                                end
                                self.pageCursor = #self.text[self.page]
                            else
                                self.lineCounter = self.lineCounter - 1
                                if self.forward then
                                    table.remove(self.lines, #self.lines)
                                    self.lines[#self.lines].w = self.lines[#self.lines].w - self.char
                                    self.pageCursor = self.pageCursor -1
                                else
                                    table.insert(self.lines, {x=self.start_x + self.pagesMapped[self.page][self.lineCounter].len*self.char,y=self.start_y+self.line*self.lineCounter,w=self.char})                 --w=self.pagesMapped[self.page][self.lineCounter].len*char})
                                end
                            end
                            self.lineCursor = self.pagesMapped[self.page][self.lineCounter].len
                        else
                            self:makeSelectText(key,self.text[self.page]:sub(self.pageCursor-1,self.pageCursor-1))
                            if self.forward then
                                self.lines[#self.lines].w = self.lines[#self.lines].w - self.char
                            else
                                self.lines[#self.lines].w = self.lines[#self.lines].w + self.char
                                self.lines[#self.lines].x = self.lines[#self.lines].x - self.char
                            end
                            self.lineCursor = self.lineCursor - 1
                            self.charIndex = self.charIndex - 1
                            self.pageCursor = self.pageCursor - 1
                        end
                    end
                end
            elseif key == 'u' then
                if not self.cursor then
                    -- TODO: exit Franzegrams
                else 
                    self.cursor = false
                end                
            end
        end,

        draw = function(self)
            love.graphics.setColor(color)
            if self.lines and self.lines[1] and self.lines[1].x then
                for _,v in ipairs(self.lines) do 
                    love.graphics.rectangle('fill',v.x,v.y,v.w,self.line)
                end
            end
        end
    }
end

function getFullPopupWindow()
    local target_x = DRAW_WIDTH/6   
    local target_y = DRAW_HEIGHT/6            
    local target_w = (DRAW_WIDTH/6)*4    
    local target_h = (DRAW_HEIGHT/6)*4
    return {target_x=target_x,target_y=target_y,target_w=target_w,target_h=target_h}
end

function getLineCount(text,char,w)
    local cursor = 0
    local lineCursor = 0
    local lines = 1
    local maxChar = math.floor(w/char)
    local newLineIndex = {}
    local index = 0 
    while true do
        index = string.find(text, '\n', index + 1)
        if index then
            table.insert(newLineIndex,index) 
        else
            break
        end
    end
    local textCopy = text
    for word in string.gmatch(textCopy, "%S+") do
        if lineCursor + #word > maxChar then
            lineCursor = 1
            lines = lines + 1
            cursor = cursor + #word
        else
            lineCursor = lineCursor + #word
            cursor = cursor + #word
        end
        if cursor + 1 == newLineIndex[1] then
            while true do
                if cursor + 1 == newLineIndex[1] then
                    lineCursor = 0
                    lines = lines + 1
                    table.remove(newLineIndex, 1)
                    cursor = cursor + 1
                else
                    break
                end
            end
            cursor = cursor - 1
        end
        cursor = cursor + 1
        if lineCursor > 1 then
            lineCursor = lineCursor + 1
        end
    end
    return lines
end

function getFullPopupText(params,popUp)
    local text = params[1]
    local buttons = params[2]
    local funcs = params[5]
    local func_params = params[6]
    local target_x = popUp.target_x
    local target_y = popUp.target_y
    local target_w = popUp.target_w
    local target_h = popUp.target_h
    local char = 14
    local line = 24
    local text_x = target_w/6 + target_x
    local text_w = (target_w/6)*4 

    local approxLines = getLineCount(text,char,target_w)
    local text_y = target_y+target_h/3-(approxLines*line)/2
    local buttonsNum = #buttons
    local x_step = target_w/(buttonsNum)
    local x_pos = {}
    local button_margin = 30
    for i=1, #buttons do
        table.insert(x_pos, target_x + button_margin + x_step*(i-1))
    end
    local button_w = text_w/#buttons
    local buttons_y = target_y+(target_h*2)/3
    local infoWindowButtons = {}
    for i,v in ipairs(buttons) do
        table.insert(infoWindowButtons, getInfoWindowButtons(v,x_pos[i],buttons_y,funcs[i],func_params[i],FONT.courier,button_w))     
    end
    for _,v in ipairs(infoWindowButtons) do
        v:open()
    end
    return {text_y=text_y,text_x=text_x,text_w=text_w,buttons_y=buttons_y,infoWindowButtons=infoWindowButtons,lines=approxLines}
end

function getLeftPopupWindow()
    local target_x = DRAW_WIDTH*0.025   
    local target_y = DRAW_HEIGHT*0.05            
    local target_w = DRAW_WIDTH*0.45    
    local target_h = DRAW_HEIGHT*0.9
    return {target_x=target_x,target_y=target_y,target_w=target_w,target_h=target_h}
end

function getLeftPopupText(params,popUp)
    local text = params[1]
    local buttons = params[2]
    local funcs = params[5]
    local func_params = params[6]
    local activeString = params[8] or 'active'
    local target_x = popUp.target_x
    local target_y = popUp.target_y
    local target_w = popUp.target_w
    local target_h = popUp.target_h
    local char = 12
    local line = 20
    local text_x = target_w/12 + target_x
    local text_w = (target_w/12)*10 
    local approxLines = getLineCount(text,char,target_w)
    local _,newLines = string.gsub(text, '\n', '\n')
    local text_y = target_y+target_h*0.45-((approxLines+(math.floor(newLines*0.75)))*line)/2
    local buttonsNum = #buttons
    local x_step = target_w/(buttonsNum)
    local buttons_y = target_y + target_h - 3.5*line
    if buttonsNum > 2 then
        x_step = target_w/2
        buttons_y = buttons_y - 3*line
    end
    local x_pos = {}
    local button_margin = 10
    for i=1, #buttons do
        if i < 3 then
            table.insert(x_pos, target_x + button_margin + x_step*(i-1))
        else
            table.insert(x_pos, target_x + button_margin + x_step*(i-3))
        end
    end
    local button_w = text_w/#buttons - 15
    if buttonsNum > 2 then
        button_w = text_w/2 - 15
    end
    local infoWindowButtons = {}
    for i,v in ipairs(buttons) do
        if i == 3 then
            buttons_y = buttons_y + 3.5*line
        end
        table.insert(infoWindowButtons, getInfoWindowButtons(v,x_pos[i],buttons_y,funcs[i],func_params[i],FONT.courierM,button_w,activeString))     
    end
    for _,v in ipairs(infoWindowButtons) do
        v:open()
    end
    return {text_y=text_y,text_x=text_x,text_w=text_w,buttons_y=buttons_y,infoWindowButtons=infoWindowButtons,lines=approxLines}
end

function buttonsLayout(buttons)

end

function getInfoWindow(params)
    local window = params[7]
    local popUp
    local fText
    local align = ''
    local font
    if window == 'full' then
        popUp = getFullPopupWindow()
        fText = getFullPopupText(params,popUp)
        align = 'center'
        font = FONT.courier
    elseif window == 'left' then
        popUp = getLeftPopupWindow()
        fText = getLeftPopupText(params,popUp)
        align = 'left'
        font = FONT.courierM
    end
    local text = params[1]
    local buttons = params[2]
    local origin_x = params[3]
    local origin_y = params[4]
    local target_x = popUp.target_x
    local target_y = popUp.target_y
    local target_w = popUp.target_w
    local target_h = popUp.target_h
    local origin_h = 0
    local origin_w = 0
    local h = 0
    local w = 0
    local window_opacity_origin = 0
    local window_opacity_target = 1
    local window_opacity = window_opacity_origin
    local text_y = fText.text_y - 25
    local text_x = fText.text_x
    local text_w = fText.text_w
    local text_opacity = 0
    local text_opacity_target = 1
    local infoWindowButtons = fText.infoWindowButtons
    local frame_opacity_origin = 0
    local frame_opacity_target = 1
    local frame_opacity = 0
    local x = origin_x
    local y = origin_y
    local selectText = ''
    local select_y = text_y + (fText.lines-1)*20 + 10
    return {
        text = text,
        buttons = buttons,
        origin_x = origin_x,
        origin_y = origin_y,
        target_x = target_x,
        target_y = target_y,
        target_w = target_w,
        target_h = target_h,
        h = h,
        w = w,
        frame_opacity_origin = frame_opacity_origin,
        frame_opacity_target = frame_opacity_target,
        frame_opacity = frame_opacity,
        window_opacity = window_opacity,
        window_opacity_origin = window_opacity_origin,
        window_opacity_target = window_opacity_target,
        text_y = text_y,
        text_x = text_x,
        text_w = text_w,
        text_opacity = text_opacity,
        text_opacity_target = text_opacity_target,
        infoWindowButtons = infoWindowButtons,
        x = x,
        y = y,
        x_step = x_step,
        origin_h = origin_h,
        origin_w = origin_w,
        align = align,
        font = font,
        selectText = selectText,
        select_y = select_y,
        select_y_const = select_y,

        open = function(self)
            Timer.tween(0.4,self,{x=self.target_x})
            Timer.tween(0.4,self,{y=self.target_y})
            Timer.tween(0.4,self,{w=self.target_w})
            Timer.tween(0.4,self,{h=self.target_h})
            Timer.tween(0.4,self,{frame_opacity=self.frame_opacity_target})
            Timer.after(0.2, function ()
                Timer.tween(0.4,self,{window_opacity=self.window_opacity_target})
                Timer.tween(0.2,self,{text_opacity=self.text_opacity_target})
                for _,v in ipairs(self.infoWindowButtons) do
                    v:open()
                end
            end)
            return 'ok'
        end,

        getSelectText = function(self,text)
            self.selectText = text
        end,

        close = function(self)
            local delay = 0
            local delay1 = 0.2
            for _,v in ipairs(infoWindowButtons) do
                delay = v:close()
            end
            Timer.tween(delay1,self,{x=self.origin_x})
            Timer.tween(delay1,self,{y=self.origin_y})
            Timer.tween(delay1,self,{w=self.origin_w})
            Timer.tween(delay1,self,{h=self.origin_h})
            Timer.tween(delay1,self,{frame_opacity=0})
            Timer.tween(0.2,self,{window_opacity=0})
            Timer.tween(0.1,self,{text_opacity=0})
            local delayTotal = math.max(delay,delay1)
            return delayTotal
        end,

        printVanish = function(self)
            Timer.tween(0.1, self, {text_opacity=0})
        end,

        draw = function(self)
            local shadow = 10
            self.select_y = self.select_y_const - math.floor(#self.selectText/30)*5
            love.graphics.setFont(self.font)
            love.graphics.setColor(0.3,0.3,0.3,self.window_opacity*0.1)
            love.graphics.rectangle('fill',self.x+shadow,self.y+shadow,self.w,self.h)
            love.graphics.setColor(1,1,0.94,self.window_opacity)
            love.graphics.rectangle('fill',self.x,self.y,self.w,self.h)
            love.graphics.setLineWidth(3)
            love.graphics.setColor(0.7,0.7,0.7,self.frame_opacity)
            love.graphics.rectangle('line',self.x,self.y,self.w,self.h)
            love.graphics.setColor(0,0,0,self.text_opacity)
            love.graphics.printf(self.text,self.text_x,self.text_y,self.text_w,self.align)
            love.graphics.printf(self.selectText,FONT.courierS,self.text_x,self.select_y,self.text_w,self.align)
        end
    }
end

function getInfoWindowButtons(button,xRaw,y,func,func_params,font,w,activeString)
    local text = button[1]
    local letter = button[2]
    local opacity_origin = 0
    local opacity_target = 1
    local opacity = 0
    local char
    if font == FONT.courier then
        char = 14
    elseif font == FONT.courierM then
        char = 12
    end
    local textLen = #text*char
    local x = xRaw
    local button_x = x - 3
    local button_y = y - 3
    local w = w or textLen + 20
    local button_w = w + 6
    local button_h = 34
    local button_red = 0
    local button_green = 1
    local button_blue = 0
    local button_opacity_origin = 0
    local button_opacity_target = 0.3
    local button_opacity = 0
    local franzegramVar = {}
    local active = true

    return {
        text = text,
        letter = letter,
        x = x,
        y = y,
        opacity_origin = opacity_origin,
        opacity_target = opacity_target,
        opacity = opacity,
        button_x = button_x,
        button_y = button_y,
        button_w = button_w,
        button_h = button_h,
        button_red = button_red,
        button_green = button_green,
        button_blue = button_blue,
        button_opacity = button_opacity,
        button_opacity_origin = button_opacity_origin,
        button_opacity_target = button_opacity_target,
        func = func,
        func_params = func_params,
        xRaw = xRaw,
        textLen = textLen,
        font = font,
        franzegramVar = franzegramVar,
        active = active,

        onClick = function(self, mouse_x,mouse_y)
            if self.active then
                if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.button_w) then
                    if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.button_h) then
                        self:onPress(self.letter)
                    end
                end 
            end
        end,

        onHover = function(self)
            if self.active then
                local mxTemp, myTemp = love.mouse.getPosition()
                local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
                local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
                if mx >= self.button_x and mx <= self.button_x + self.button_w then
                    if my >= self.button_y and my <= self.button_y + self.button_h then
                        self.button_opacity = 0.3
                    else
                        self.button_opacity = 0
                    end
                end
            end
        end,

        deactivate = function(self)
            self.active = false
        end,

        activate = function(self)
            self.active = true
        end,

        open = function(self)
            Timer.tween(0.2,self,{opacity=self.opacity_target})
        end,

        close = function(self)
            Timer.tween(0.2,self,{opacity=0})
            Timer.tween(0.2,self,{button_opacity=0})
            return 0.2
        end,

        onPress = function(self,key)
            if self.active then
                if key == self.letter then
                    if self.func == franzegram then
                        self.franzegramVar = self.func(self.func_params)
                        self:deactivate()
                    elseif self.func == reopenBook then
                        closeInfoWindows()
                        self.func(self.func_params)
                    elseif self.func == getGif then
                        getGif(INFOWINDOWS[#INFOWINDOWS].selectText)
                    elseif self.func == 'franzeVar' then
                        for _,v in ipairs(INFOWINDOWS) do
                            v:draw()
                            if v.infoWindowButtons then
                                for _,w in ipairs(v.infoWindowButtons) do
                                    if w.franzegramVar and w.franzegramVar.onPress then
                                        w.franzegramVar:onPress(key,self.text)
                                    end
                                end
                            end
                        end
                    else
                        self.func(self.func_params)
                    end
                end
            end
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1,self.button_opacity)
            love.graphics.rectangle('fill',self.button_x,self.button_y,self.button_w,self.button_h)
            love.graphics.setColor(self.button_red,self.button_green,self.button_blue,self.button_opacity)
            love.graphics.rectangle('fill',self.button_x,self.button_y,self.button_w,self.button_h)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.printf(self.text,self.x,self.y,self.button_w,'center')
        end
    }
end

function infoBoard(x,y,w,origin_x,origin_y,numKeys)
    local numKeys = numKeys or 8
    local board_vert1_x = origin_x
    local board_vert2_x = origin_x
    local board_vert3_x = origin_x
    local board_vert4_x = origin_x
    local board_vert1_y = origin_y
    local board_vert2_y = origin_y
    local board_vert3_y = origin_y
    local board_vert4_y = origin_y
    local board_vert1_x_target = x
    local board_vert2_x_target = x + w
    local board_vert3_x_target = x + 1.2*w                                                                                          
    local board_vert4_x_target = x + 0.2*w
    local board_vert1_y_target = y                                     
    local board_vert2_y_target = y
    local board_vert3_y_target = y + 0.6*w
    local board_vert4_y_target = y + 0.6*w
    local board_origin_x = origin_x
    local board_origin_y = origin_y
    local opacity_origin = 0
    local opacity = opacity_origin
    local opacity_target = 1
    local keys = {}
    for i = 1, numKeys do
        table.insert(keys,getKeys(x,y,w,i))
    end
    local key_opacity_origin = 0
    local key_opacity_target = 1
    local key_opacity = key_opacity_origin
    local line_x_origin = 0
    local line_x_target = 300
    local line_x = line_x_origin
    local line_y1_origin = 450
    local line_y2_origin = 450
    local line_y1_target = y + 0.6*w
    local line_y2_target = y
    local line_y1 = line_y1_origin
    local line_y2 = line_y2_origin
    local line_opacity_origin = 0
    local line_opacity_target = 0.5
    local line_opacity = line_opacity_origin

    local line2_x1_origin = 750
    local line2_x1_target = 725
    local line2_x1 = line2_x1_origin
    local line2_x2_origin = 750
    local line2_x2_target = 625
    local line2_x2 = line2_x2_origin
    local line2_y1_origin = 550
    local line2_y2_origin = 550
    local line2_y1_target = 525
    local line2_y2_target = y + 0.6*w
    local line2_y1 = line2_y1_origin
    local line2_y2 = line2_y2_origin
    local line2_opacity_origin = 0
    local line2_opacity_target = 0.5
    local line2_opacity = line2_opacity_origin
    local topText = 'Test Nav Keys'
    local topText_char = 29
    local topText_opacity = 0
    local topText_opacity_origin = 0
    local topText_opacity_target = 1
    local topText_x_origin = DRAW_WIDTH/2 - #topText*topText_char/2
    local topText_x_target = board_vert1_x_target + w/2 - #topText*29/2
    local topText_x = topText_x_origin
    local bottomText = "Double-click 'i' to close"
    local bottomText_char = 14
    local bottomText_x_origin = DRAW_WIDTH/2 - #bottomText*bottomText_char/2
    local bottomText_x_target = board_vert4_x_target + w/2 - #bottomText*bottomText_char/2
    local bottomText_opacity_origin = 0
    local bottomText_opacity = 0
    local bottomText_opacity_target = 1
    local topVignette_w = #topText*19
    local topVignette_h = 50
    local topVignette_x = board_vert1_x_target + 10 + w/2 - #topText*19/2
    local topVignette_opacity_origin = 0
    local topVignette_opacity_target = 0.7
    local topVignette_opacity = topVignette_opacity_origin
    local bottomVignette_w = #bottomText*bottomText_char
    local bottomVignette_h = 50
    local bottomVignette_opacity_origin = 0
    local bottomVignette_opacity_target = 0.7
    local bottomVignette_opacity = topVignette_opacity_origin

    return {
        line2_x1 = line2_x1,
        line2_x2 = line2_x2,
        line2_y1 = line2_y1,
        line2_y2 = line2_y2,
        line2_x1_origin = line2_x1_origin,
        line2_x1_target = line2_x1_target,
        line2_x2_origin = line2_x2_origin,
        line2_x2_target = line2_x2_target,
        line2_y1_origin = line2_y1_origin,
        line2_y2_origin = line2_y2_origin,
        line2_y1_target = line2_y1_target,
        line2_y2_target = line2_y2_target,
        line2_opacity = line2_opacity,
        line2_opacity_origin = line2_opacity_origin,
        line2_opacity_target = line2_opacity_target,
        key_opacity = key_opacity,
        key_opacity_origin = key_opacity_origin,
        key_opacity_target = key_opacity_target,
        board_origin_x = board_origin_x,
        board_origin_y = board_origin_y,
        board_vert1_x = board_vert1_x,
        board_vert2_x = board_vert2_x,
        board_vert3_x = board_vert3_x,
        board_vert4_x = board_vert4_x,
        board_vert1_y = board_vert1_y,
        board_vert2_y = board_vert2_y,
        board_vert3_y = board_vert3_y,
        board_vert4_y = board_vert4_y,
        board_vert1_x_target = board_vert1_x_target,
        board_vert2_x_target = board_vert2_x_target,
        board_vert3_x_target = board_vert3_x_target,
        board_vert4_x_target = board_vert4_x_target,
        board_vert1_y_target = board_vert1_y_target,
        board_vert2_y_target = board_vert2_y_target,
        board_vert3_y_target = board_vert3_y_target,
        board_vert4_y_target = board_vert4_y_target,
        opacity = opacity,
        opacity_origin = opacity_origin,
        opacity_target = opacity_target,
        keys = keys,
        line_x = line_x,
        line_y1 = line_y1,
        line_y2 = line_y2,
        line_x_origin = line_x_origin,
        line_x_target = line_x_target,
        line_y1_origin = line_y1_origin,
        line_y1_target = line_y1_target,
        line_y2_origin = line_y2_origin,
        line_y2_target = line_y2_target,
        line_opacity = line_opacity,
        line_opacity_origin = line_opacity_origin,
        line_opacity_target = line_opacity_target,
        width = w,
        topText_opacity = topText_opacity,
        topText_opacity_origin = topText_opacity_origin,
        topText_opacity_target = topText_opacity_target,
        topText_x = topText_x,
        topText_x_origin = topText_x_origin,
        topText_x_target = topText_x_target,
        topText = topText,
        bottomText = bottomText,
        bottomText_x_origin = bottomText_x_origin,
        bottomText_x_target = bottomText_x_target,
        bottomText_opacity = bottomText_opacity,
        bottomText_opacity_origin = bottomText_opacity_origin,
        bottomText_opacity_target = bottomText_opacity_target,
        topVignette_h = topVignette_h,
        topVignette_opacity = topVignette_opacity,
        topVignette_opacity_origin = topVignette_opacity_origin,
        topVignette_opacity_target = topVignette_opacity_target,
        topVignette_w = topVignette_w,
        bottomVignette_h = bottomVignette_h,
        bottomVignette_opacity = bottomVignette_opacity,
        bottomVignette_opacity_origin = bottomVignette_opacity_origin,
        bottomVignette_opacity_target = bottomVignette_opacity_target,
        bottomVignette_w = bottomVignette_w,
        topVignette_x = topVignette_x,

        open = function(self)
            local delay = 1
            local mode = 'in-out-cubic'
            Timer.tween(0.2,self,{line_opacity=self.line_opacity_target},mode)
            Timer.tween(0.5, self,{line_y1=self.line_y1_target},mode) 
            Timer.tween(0.5, self,{line_y2=self.line_y2_target},mode)
            Timer.after(0.5,function()
                Timer.tween(0.8,self,{line_x=line_x_target},mode)
                Timer.tween(0.8,self,{line_opacity=0},mode)
                self.board_vert1_y = self.board_vert1_y_target
                self.board_vert2_y = self.board_vert2_y_target
                self.board_vert3_y = self.board_vert3_y_target
                self.board_vert4_y = self.board_vert4_y_target
                Timer.tween(delay, self, {board_vert1_x = self.board_vert1_x_target}, mode)
                Timer.tween(delay, self, {board_vert2_x = self.board_vert2_x_target}, mode)
                Timer.tween(delay, self, {board_vert3_x = self.board_vert3_x_target}, mode)
                Timer.tween(delay, self, {board_vert4_x = self.board_vert4_x_target}, mode)
                Timer.after(0.2, function() Timer.tween(0.5, self, {opacity = self.opacity_target},'in-cubic') end)
                Timer.after(0.1, function()
                    for i,v in ipairs(self.keys) do
                        Timer.after((i-1)*0.05, function() v:open() end)
                    end
                end)
                Timer.tween(0.1, self, {key_opacity = self.key_opacity_target})
            end)
            Timer.after(0.1, function()
                Timer.tween(0.2,self,{topText_opacity=self.topText_opacity_target})
                Timer.after(0.8, function()
                    Timer.tween(0.3,self,{topText_x=self.topText_x_target},'in-out-quad')
                end)
            end)
            Timer.after(1.5, function()
                Timer.tween(0.2,self,{bottomText_opacity=self.bottomText_opacity_target})
            end)
            Timer.after(1.2, function()
                Timer.tween(0.3,self,{topVignette_opacity=topVignette_opacity_target})
            end)
            Timer.after(1.6, function()
                Timer.tween(0.3,self,{bottomVignette_opacity=bottomVignette_opacity_target})
            end)
        end,

        open2 = function(self)
            local delay = 1
            local mode = 'in-out-cubic'
            Timer.tween(0.2,self,{line2_opacity=self.line2_opacity_target},mode)
            Timer.tween(0.5, self,{line2_y1=self.line2_y1_target},mode) 
            Timer.tween(0.5, self,{line2_y2=self.line2_y2_target},mode)
            Timer.tween(0.5, self,{line2_x1=self.line2_x1_target},mode) 
            Timer.tween(0.5, self,{line2_x2=self.line2_x2_target},mode)
            Timer.after(0.3,function()
                Timer.tween(0.4,self,{line2_opacity=0},mode)
                self.board_vert1_y = self.board_vert1_y_target
                self.board_vert2_y = self.board_vert2_y_target
                self.board_vert3_y = self.board_vert3_y_target
                self.board_vert4_y = self.board_vert1_y_target
                self.board_vert1_x = self.board_vert1_x_target
                self.board_vert2_x = self.board_vert1_x_target
                self.board_vert3_x = self.board_vert3_x_target
                self.board_vert4_x = self.board_vert1_x_target
                Timer.tween(0.4,self,{line2_x1=self.line2_x2_target},mode) 
                Timer.tween(0.4,self,{line2_y1=self.line2_y2_target},mode) 
                Timer.tween(delay, self, {board_vert2_x = self.board_vert2_x_target}, mode)
                Timer.tween(delay, self, {board_vert4_x = self.board_vert4_x_target}, mode)
                Timer.tween(delay, self, {board_vert4_y = self.board_vert4_y_target}, mode)
                Timer.after(0.2, function() Timer.tween(0.5, self, {opacity = self.opacity_target},'in-cubic') end)
                Timer.after(0.5, function()
                    for i,v in ipairs(self.keys) do
                        Timer.after((i-1)*0.05, function() v:open() end)
                    end
                end)
                Timer.tween(0.1, self, {key_opacity = self.key_opacity_target})
            end)
            Timer.after(0.1, function()
                Timer.tween(0.2,self,{topText_opacity=self.topText_opacity_target})
                Timer.after(0.8, function()
                    Timer.tween(0.5,self,{topText_x=self.topText_x_target},'in-out-quad')
                end)
            end)
            Timer.after(1.5, function()
                Timer.tween(0.2,self,{bottomText_opacity=self.bottomText_opacity_target})
            end)
            Timer.after(1.2, function()
                Timer.tween(0.3,self,{topVignette_opacity=topVignette_opacity_target})
            end)
            Timer.after(1.6, function()
                Timer.tween(0.3,self,{bottomVignette_opacity=bottomVignette_opacity_target})
            end)
        end,


        close = function(self)
            local delay = 0.4
            local delay2 = 0.4
            local mode = 'in-cubic'
            local mode2 = 'in-quint'
            local backwards = {}
            for i = #self.keys, 1, -1 do
                table.insert(backwards, i) 
            end
            for i,v in ipairs(self.keys) do
                Timer.after((backwards[i]-1)*0.05, function() v:close() end)
            end
            Timer.tween(0.2,self,{topText_opacity=self.topText_opacity_origin})
            Timer.tween(0.1,self,{bottomText_opacity=self.bottomText_opacity_origin})
            Timer.tween(0.1,self,{topVignette_opacity=self.topVignette_opacity_origin})
            Timer.tween(0.1,self,{bottomVignette_opacity=self.bottomText_opacity_origin})
            Timer.after(0.1, function()
                Timer.tween(delay2, self, {board_vert1_x = self.board_origin_x-2}, mode2)
                Timer.tween(delay2, self, {board_vert2_x = self.board_origin_x+2}, mode2)
                Timer.tween(delay2, self, {board_vert3_x = self.board_origin_x+2}, mode2)
                Timer.tween(delay2, self, {board_vert4_x = self.board_origin_x-2}, mode2)
                Timer.after(0.2, function()
                    Timer.tween(delay, self, {board_vert1_y = self.board_origin_y}, mode)
                    Timer.tween(delay, self, {board_vert2_y = self.board_origin_y}, mode)
                    Timer.tween(delay, self, {board_vert3_y = self.board_origin_y}, mode)
                    Timer.tween(delay, self, {board_vert4_y = self.board_origin_y}, mode)
                    Timer.tween(delay, self, {opacity = 0},'in-cubic')
                end)
            end)
            return 0.1+delay2+delay
        end,

        close2 = function(self)
            local delay = 0.4
            local delay2 = 0.4
            local mode = 'in-cubic'
            local mode2 = 'in-quint'
            local backwards = {}
            for i = #self.keys, 1, -1 do
                table.insert(backwards, i) 
            end
            for i,v in ipairs(self.keys) do
                Timer.after((backwards[i]-1)*0.05, function() v:close() end)
            end
            Timer.tween(0.2,self,{topText_opacity=self.topText_opacity_origin})
            Timer.tween(0.1,self,{bottomText_opacity=self.bottomText_opacity_origin})
            Timer.tween(0.1,self,{topVignette_opacity=self.topVignette_opacity_origin})
            Timer.tween(0.1,self,{bottomVignette_opacity=self.bottomText_opacity_origin})
            Timer.after(0.1, function()
                Timer.tween(delay, self, {board_vert2_x = self.board_vert1_x_target}, mode)
                Timer.tween(delay, self, {board_vert4_x = self.board_vert1_x_target}, mode)
                Timer.tween(delay, self, {board_vert4_y = self.board_vert1_y_target}, mode)
                Timer.tween(delay,self, {line2_opacity = self.line2_opacity_target}, mode)
                Timer.after(delay,function()
                    Timer.tween(0.1,self,{board_vert2_x = self.board_vert3_x_target}, mode) 
                    Timer.tween(0.1,self,{board_vert4_x = self.board_vert3_x_target}, mode)
                    Timer.tween(0.1,self,{board_vert4_y = self.board_vert3_y_target}, mode)
                    Timer.tween(0.1,self,{board_vert1_x = self.board_vert3_x_target}, mode)
                    Timer.tween(0.1,self,{board_vert1_y = self.board_vert3_y_target}, mode)
                    Timer.tween(0.1,self,{board_vert2_y = self.board_vert3_y_target}, mode)
                    Timer.tween(0.2,self,{opacity = 0})
                    Timer.tween(0.3,self,{line2_opacity=0},mode)
                    Timer.tween(0.1, self,{line2_y1=self.line2_y1_origin},mode) 
                    Timer.tween(0.3, self,{line2_y2=self.line2_y2_origin},mode)
                    Timer.tween(0.1, self,{line2_x1=self.line2_x1_origin},mode) 
                    Timer.tween(0.3, self,{line2_x2=self.line2_x2_origin},mode)
                end)
            end)
            return 0.1+delay+0.3
        end,

        draw = function(self)
            local shadow = 20
            love.graphics.setColor(1,1,1,self.topVignette_opacity)
            love.graphics.rectangle('fill',self.topVignette_x-10,self.board_vert1_y_target-50,self.topVignette_w+20,self.topVignette_h)
            love.graphics.setColor(1,1,1,self.bottomVignette_opacity)
            love.graphics.rectangle('fill',self.bottomText_x_target-10,self.board_vert4_y_target+5,self.bottomVignette_w+20,self.bottomVignette_h)
            love.graphics.setLineWidth(6)
            love.graphics.setColor(0.3,0.3,0.3,self.opacity*0.1)
            love.graphics.polygon('fill',self.board_vert1_x,self.board_vert1_y,self.board_vert2_x+shadow,self.board_vert2_y+shadow,self.board_vert3_x+shadow,self.board_vert3_y+shadow,self.board_vert4_x+shadow,self.board_vert4_y+shadow)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.setColor(0.8,0.8,0.8)
            love.graphics.polygon('fill',self.board_vert1_x,self.board_vert1_y,self.board_vert2_x,self.board_vert2_y,self.board_vert3_x,self.board_vert3_y,self.board_vert4_x,self.board_vert4_y)
            for _,v in ipairs(self.keys) do
                v:draw()
            end
            love.graphics.setColor(0.4,0.4,0.4,self.line_opacity)
            love.graphics.line(400+self.line_x,self.line_y1,400+self.line_x,self.line_y2)
            love.graphics.line(400-self.line_x,self.line_y1,400-self.line_x,self.line_y2)
            love.graphics.setColor(0.4,0.4,0.4,self.line2_opacity)
            love.graphics.line(self.line2_x1,self.line2_y1,self.line2_x2,self.line2_y2)
            love.graphics.setFont(FONT.notoBlack)
            love.graphics.setColor(0.8,0,0,self.topText_opacity)
            love.graphics.printf(self.topText,self.topText_x,self.board_vert1_y_target-50,self.width,'center')
            love.graphics.setColor(0.8,0,0,self.bottomText_opacity)
            love.graphics.setFont(FONT.notoBlackS)
            love.graphics.print(self.bottomText,self.bottomText_x_target,self.board_vert4_y_target+5)
        end
    }
end

function getKeys(x,y,width,index)
    local step = math.floor(width/11)
    local height = width*0.6
    local h1 = y + height*0.1
    local h2 = y + height*0.6
    local h3 = y + height*1.2
    local h4 = y + height*0.5
    local h5 = y + height*0.35
    local target_x = 0
    local target_y = 0
    local letter = ''
    local red_target = 0
    local blue_target = 0
    local green_target = 0
    local target_w = step*2
    local target_h = (height*0.7)/2
    if index == 1 then
        target_x = x+step*2
        target_y = h1    
        letter = 'u'
        --red
        red_target = 1
        blue_target = 0
        green_target = 0
    elseif index == 2 then
        target_x = x+step*5
        target_y = h1
        letter = 'i'
        --lightgray
        red_target = 0.7
        green_target = 0.7
        blue_target = 0.7
    elseif index == 3 then
        target_x = x+step*8
        target_y = h1
        letter = 'o'
        --lightblue
        red_target = 0.26
        green_target = 0.75
        blue_target = 0.98
    elseif index == 4 then
        target_x = x+step*3
        target_y = h2
        letter = 'j'
        --pink
        red_target = 1
        green_target = 0.2
        blue_target = 0.7
    elseif index == 5 then
        target_x = x+step*6
        target_y = h2
        letter = 'k'
        --lightgray
        red_target = 0.7
        green_target = 0.7
        blue_target = 0.7
    elseif index == 6 then
        target_x = x+step*9
        target_y = h2
        letter = 'l'
        --blue
        red_target = 0
        green_target = 0
        blue_target = 1
    elseif index == 7 then 
        target_x = x+step*12.5
        target_w = step*4
        target_y = y 
        letter = 'bkspc'
        -- title blue
        red_target = 0.9
        green_target = 0.9
        blue_target = 1
    elseif index == 8 then 
        target_x = x-step*3.5
        target_y = h5 
        target_w = step*4
        letter = 'esc'
        -- title blue
        red_target = 0.9
        green_target = 0.9
        blue_target = 1
--[[     elseif index == 9 then
        target_x = x-step*2
        target_y = h3
        target_w = step*8
        letter = 'space'
        --darkpurple
        red_target = 0.21
        green_target = 0
        blue_target = 0.25 ]]
    elseif index == 9 then
        target_x = x+step*13.5
        target_w = step*4
        target_y = h4
        letter = 'return'
        --red
        red_target = 1
        green_target = 0
        blue_target = 0
    end
    local origin_x = target_x+step
    local origin_y = target_y+(height*0.7)/4
    local x = origin_x
    local y = origin_y
    local origin_w = 0
    local origin_h = 0
    local w = origin_w
    local h = origin_h
    local opacity_origin = 0
    local opacity_target = 1
    local opacity = opacity_origin
    local rx = width/10
    local yx = height/10
    local letter_opacity = 0
    local letter_scale = 1
    local letter_target_opacity = 1
    local letter_origin_opacity = 0
    local red_origin = 0.9
    local blue_origin = 0.9
    local green_origin = 0.9
    local shrinkFactor = 0.95
    local shrink_w = target_w*shrinkFactor
    local shrink_h = target_h*shrinkFactor
    local shrink_x = target_x + (target_w - shrink_w)/2
    local shrink_y = target_y + (target_h - shrink_h)/2
    local text_red_origin = 0.2
    local text_green_origin = 0.2
    local text_blue_origin = 0.2
    local text_red_target = 1
    local text_green_target = 1
    local text_blue_target = 1

    return {
        text_blue_origin = text_blue_origin,
        text_blue_target = text_blue_target,
        text_green_origin = text_green_origin,
        text_green_target = text_green_target,
        text_red_origin = text_red_origin,
        text_red_target = text_red_target,
        text_red = text_red_origin,
        text_green = text_green_origin,
        text_blue = text_blue_origin,
        shrink_w = shrink_w,
        shrink_h = shrink_h,
        shrink_x = shrink_x,
        shrink_y = shrink_y,
        red = red_origin,
        blue = blue_origin,
        green = green_origin,
        origin_red = red_origin,
        target_red = red_target,
        origin_blue = blue_origin,
        target_blue = blue_target,
        origin_green = green_origin,
        target_green = green_target,
        letter = letter,
        letter_x = target_x,
        letter_y = origin_y-(36/2),
        letter_opacity = letter_opacity,
        letter_scale = letter_scale,
        letter_origin_opacity = letter_origin_opacity,
        letter_target_opacity = letter_target_opacity,
        target_x = target_x,
        target_y = target_y,
        origin_x = origin_x,
        origin_y = origin_y,
        origin_w = origin_w, 
        origin_h = origin_h,
        target_w = target_w,
        target_h = target_h,
        x = x,
        y = y,
        w = w,
        h = h,
        rx = rx,
        yx = yx,
        opacity = opacity,
        opacity_origin = opacity_origin,
        opacity_target = opacity_target,

        open = function(self)
            local delay = 0.1
            local mode = 'in-out-cubic'
            Timer.tween(delay,self,{x=self.target_x},mode)
            Timer.tween(delay,self,{y=self.target_y},mode)
            Timer.tween(delay,self,{w=self.target_w},mode)
            Timer.tween(delay,self,{h=self.target_h},mode)
            Timer.tween(delay,self,{opacity = self.opacity_target}, mode)
            Timer.after(delay, function()
                Timer.tween(delay,self,{letter_opacity = self.letter_target_opacity},'in-quint')
            end)
        end,

        close = function(self)
            local delay = 0.1
            local mode = 'in-out-cubic'
            Timer.tween(delay,self,{x=origin_x},mode)
            Timer.tween(delay,self,{y=origin_y},mode)
            Timer.tween(delay,self,{w=origin_w},mode)
            Timer.tween(delay,self,{h=origin_h},mode)
            Timer.tween(delay,self,{opacity = self.opacity_origin}, mode)
            Timer.tween(0.1,self,{letter_opacity = self.letter_origin_opacity},'in-quint')
        end,

        onPress = function(self)
            local mode = 'in-quad'
            self.x = self.shrink_x
            self.y = self.shrink_y
            self.w = self.shrink_w
            self.h = self.shrink_h
            Timer.after(0.1, function()
                Timer.tween(0.1,self,{x=self.target_x},mode)
                Timer.tween(0.1,self,{y=self.target_y},mode)
                Timer.tween(0.1,self,{w=self.target_w},mode)
                Timer.tween(0.1,self,{h=self.target_h},mode)
            end)
        end,

        glow = function(self,key,delay)
            delay = 0.2
            if key == self.letter then
                self.red = self.target_red
                self.blue = self.target_blue
                self.green = self.target_green
                Timer.tween(delay,self,{red=self.origin_red},'in-quint')
                Timer.tween(delay,self,{green=self.origin_green},'in-quint')
                Timer.tween(delay,self,{blue=self.origin_blue},'in-quint')
            end
        end,

        draw = function(self)
            love.graphics.setLineWidth(4)
            love.graphics.setColor(0.4,0.4,0.4,self.opacity)
            love.graphics.rectangle('line',self.x,self.y,self.w,self.h,self.rx,self.yx)
            love.graphics.setColor(self.red,self.green,self.blue,self.opacity)
            love.graphics.rectangle('fill',self.x,self.y,self.w,self.h,self.rx,self.yx)
            love.graphics.setColor(self.text_red,self.text_green,self.text_blue,self.letter_opacity)
            love.graphics.printf(self.letter,FONT.courierXL,self.letter_x,self.letter_y,self.target_w,'center')
        end
    }

end


function getArrow(sx,sy,ex,ey)
    -- get midpoint (mx,my): will be origin endpoint
    local mx = sx + (ex - sx) * 0.5 
    local my = sy + (ey - sy) * 0.5
    -- get origin coordinates
    local origin = getArrowCoords(sx,sy,mx,my)

    -- get target start point (tsx,tsy)
    local tsx = sx + (ex - sx) * 0.2 
    local tsy = sy + (ey - sy) * 0.2
    -- get target coordinates
    local target = getArrowCoords(tsx,tsy,ex,ey)

    -- initialize actual coordinates
    local coords = origin

    return {
        origin = origin,
        target = target,
        coords = coords,

        open = function(self)
            for i,v in ipairs(self.coords) do
                Timer.Tween(1,v,{val=target[i].val})
            end
        end,

        draw = function(self)
            local verts = {}
            for i,v in ipairs(self.coords) do
                table.insert(verts,v.val)
            end
            love.graphics.polygon('fill',verts)
        end
    }
end

function getArrowCoords(sx,sy,ex,ey,index)
    local per = 0.8
    local per2 = 0.2
    local per3 = 0.06
    local jx = sx + (ex - sx) * per
    local jy = sy + (ey - sy) * per
    local arrowSlope = (ey - sy) / (ex - sx)
    local yIntercept = sy - (arrowSlope * sx)
    local wingSlope = -1 * (1 / arrowSlope)
    local yWingIntercept = jy - (wingSlope * jx)
    local len = math.sqrt((ex - sx) ^ 2 + (ey - sy) ^ 2)
    local wingLen = 0.2 * len
    local nookLen = 0.06 * len
    local coords = {{val=ex},{val=ey}}
    local x2
    local y2
    local x3
    local y3
    local x4
    local y4
    local x5
    local y5
    local x6
    local y6
    local x7
    local y7
    if  wingSlope > 3 then
        wingSlope = 3
    elseif wingSlope < -3 then
        wingSlope = -3
    end 
    if wingSlope < 2.5 and wingSlope > -2.5 then
        x2 = math.cos(wingSlope)*wingLen + jx
        y2 = wingSlope*(x2 - jx) + jy
        x3 = math.cos(wingSlope)*nookLen + jx
        y3 = wingSlope*(x3 - jx) + jy
        x4 = math.cos(wingSlope)*nookLen + sx
        y4 = wingSlope*(x4 - sx) + sy
        x5 = -1*math.cos(wingSlope)*nookLen + sx
        y5 = wingSlope*(x5 - sx) + sy
        x6 = -1*math.cos(wingSlope)*nookLen + jx
        y6 = wingSlope*(x6 - jx) + jy
        x7 = -1*math.cos(wingSlope)*wingLen + jx
        y7 = wingSlope*(x7 - jx) + jy
    else
        x2 = math.sin(wingSlope)*wingLen + jx
        y2 = wingSlope*(x2 - jx) + jy
        x3 = math.sin(wingSlope)*nookLen + jx
        y3 = wingSlope*(x3 - jx) + jy
        x4 = math.sin(wingSlope)*nookLen + sx
        y4 = wingSlope*(x4 - sx) + sy
        x5 = -1*math.sin(wingSlope)*nookLen + sx
        y5 = wingSlope*(x5 - sx) + sy
        x6 = -1*math.sin(wingSlope)*nookLen + jx
        y6 = wingSlope*(x6 - jx) + jy
        x7 = -1*math.sin(wingSlope)*wingLen + jx
        y7 = wingSlope*(x7 - jx) + jy
    end
    table.insert(coords,{val=x2})
    table.insert(coords,{val=y2})
    table.insert(coords,{val=x3})
    table.insert(coords,{val=y3})
    table.insert(coords,{val=x4})
    table.insert(coords,{val=y4})
    table.insert(coords,{val=x5})
    table.insert(coords,{val=y5})
    table.insert(coords,{val=x6})
    table.insert(coords,{val=y6})
    table.insert(coords,{val=x7})
    table.insert(coords,{val=y7})

    return coords

end