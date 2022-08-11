function getMugIcon()
    local x = 700
    local y = 0
    local scale = 0.2
    local opacity = 0.2
    local settingsPage = false
    local button_w = 100
    local button_h = 100
    local explainer = {}
    local explainerCount = 0
    local button_opacity = 0

    return {
        x = x,
        y = y,
        button_w = button_w,
        button_h = button_h,
        scale = scale,
        opacity = opacity,
        settingsPage = settingsPage,
        explainer = explainer,
        explainerCount = explainerCount,
        button_opacity = button_opacity,

        onClick = function(self,mouse_x,mouse_y)
            if (mouse_x >= self.x) and (mouse_x <= self.x + self.button_w) then
                if (mouse_y >= self.y) and (mouse_y <= self.y + self.button_h) then
                    self:onPress('backspace')
                end
            end 
        end,

        onPress = function(self,key)
            if key == 'backspace' then
                if MENUS and MENUS[1] then
                    self.settingsPage = false
                    if self.explainer and self.explainer.interrupt then
                        self.explainer:interrupt()
                    end
                    hideSettings()
                else
                    self.settingsPage = true
                    showSettings()
                    if self.explainerCount < 3 then
                        self.explainer = explainSettings()
                        self.explainer:open()
                    end
                    self.explainerCount = self.explainerCount + 1
                end
            end
        end,

        keyTest = function(self, key) 
            if INFO and INFO.keys then
                if key == 'backspace' then
                    for _,v in ipairs(INFO.keys) do
                        v:glow('bkspc',0.1)
                        self:goLight()
                    end
                end
            end
        end,

        goLight = function(self)
            self.button_opacity = 1
            Timer.tween(4,self,{button_opacity=0})
        end,

        draw = function(self)
            love.graphics.setColor(0.9,0.9,1,self.button_opacity)
            love.graphics.rectangle('fill',self.x,self.y,self.button_w,self.button_h)
            love.graphics.setColor(1,1,1,self.opacity)
            love.graphics.draw(ICONS.mug, self.x, self.y, nil, self.scale)
            if self.explainer and self.explainer.texts then
                self.explainer:draw()
            end
        end
    }
end

function getTwIcon(x,y,scale)
    local tw_x = x or 20 
    local read_x = 285
    local x = tw_x 
    local y = y or 15
    local scale = scale or 0.2
    local tw_image = ICONS.twNo
    local read_image = ICONS.twYes
    local image = read_image
    local safeWrite = false
    local circle_r_origin = 0
    local circle_r_target = 35
    local circle_r = circle_r_origin
    local circle_w_origin = 0
    local circle_w_target = 12
    local circle_w = circle_w_origin
    local circle_opacity_origin = 0
    local circle_opacity_target = 0.4
    local circle_opacity = circle_opacity_origin
    local line_x2 = x + 70
    local line_y2 = y + 70
    local circle_r_pop = 50
    local circle_w_pop = 25
    local voidCircle = false
    local readMode = false
    local button_w = 100
    local button_h = 100
    local button_opacity = 0

    return {
        voidCircle = voidCircle,
        circle_r_pop = circle_r_pop,
        circle_w_pop = circle_w_pop,
        circle_r = circle_r,
        circle_w = circle_w,
        circle_opacity = circle_opacity,
        line_x2 = line_x2,
        line_y2 = line_y2,
        circle_r_origin = circle_r_origin,
        circle_w_origin = circle_w_origin,
        circle_opacity_origin = circle_opacity_origin,
        circle_r_target = circle_r_target,
        circle_w_target = circle_w_target,
        circle_opacity_target = circle_opacity_target,
        safeWrite = safeWrite,
        tw_x = tw_x,
        read_x = read_x,
        tw_image = tw_image,
        read_image = read_image,
        image = image,
        y = y,
        x = x,
        readMode = readMode,
        button_w = button_w,
        button_h = button_h,
        scale = scale,
        button_opacity = button_opacity,

        onClick = function(self,mouse_x,mouse_y)
            if (mouse_x >= self.x) and (mouse_x <= self.x + self.button_w) then
                if (mouse_y >= self.y) and (mouse_y <= self.y + self.button_h) then
                    if INFOWINDOWS and INFOWINDOWS[1] then 
                        return
                    else
                        self:onPress('escape')
                    end
                end
            end 
        end,

        onPress = function(self,key)
            if INFOWINDOWS and INFOWINDOWS[1] then
                return
            end
            if key == 'escape' then
                if DELAY_HANDLES then 
                    for _,v in ipairs(DELAY_HANDLES) do 
                        Timer.cancel(v)
                    end
                    DELAY_HANDLES = {}
                end 
                if self.readMode then
                    local delay1 = hideSettings() or 0.01
                    local delay2 = 0.01
                    Timer.after(delay1, function() 
                        Timer.after(delay2,function()
                            READER.readButtons = {}
                            TYPEWRITER_MODE = true
                            self:toTw()
                            self.readMode = false
                            hideSettings()
                            READER = {}
                        end)
                    end)
                else
                    if MENUS and MENUS[1] then
                        if MUGICON.explainer and MUGICON.explainer.interrupt then
                            MUGICON.explainer:interrupt()
                        end
                    end
                    local delay = TYPEWRITER:removeFast()
                    Timer.after(delay, function()
                        TYPEWRITER_MODE = false
                        TYPEWRITER:bookmarkIt()
                        TYPEWRITER = {}
                        hideSettings()
                        self.readMode = true 
                        self:toRead()          
                    end)
                end
            end
        end,

        keyTest = function(self, key)
            if INFO and INFO.keys then
                if key == 'escape' then
                    for _,v in ipairs(INFO.keys) do
                        v:glow('esc',0.1)
                        self:goLight()
                    end
                end
            end
        end,

        goLight = function(self)
            self.button_opacity = 1
            Timer.tween(4,self,{button_opacity=0})
        end,

        toSettings = function(self)
            Timer.tween(1,self,{x=self.tw_x},'in-out-cubic')
        end,

        fromSettings = function(self)
            if not TYPEWRITER_MODE then
                Timer.tween(1,self,{x=self.read_x},'in-out-cubic')
            end
        end,

        toRead = function(self)
            READER = reader()
            if self.voidCircle then
                self.safeWrite = true
                local delay1 = 0.2
                local delay2 = 0.1
                Timer.tween(delay1,self,{line_x2=self.x+25}, 'out-cubic')
                Timer.tween(delay1,self,{line_y2=self.y+25}, 'out-cubic')
                Timer.after(delay1, function()
                    for _,v in ipairs(READER.readButtons) do 
                        v:open() 
                    end
                    Timer.tween(delay2,self,{circle_r=self.circle_r_pop},'in-cubic')
                    Timer.tween(delay2,self,{circle_w=self.circle_w_pop},'in-cubic')
                    Timer.tween(delay1+delay2,self,{circle_opacity=self.circle_opacity_origin},'in-cubic')
                    Timer.after(delay2, function()
                        Timer.tween(delay1,self,{circle_r=self.circle_r_origin},'in-cubic')
                        Timer.tween(delay1,self,{circle_w=self.circle_w_origin},'in-cubic')
                        Timer.after(delay1*2+delay2, function()
                            self.safeWrite = false
                            Timer.tween(1,self,{x=self.read_x},'in-out-cubic')
                        end)
                    end)
                end)
            else
                Timer.tween(1,self,{x=self.read_x},'in-out-cubic')
            end
        end,

        toTw = function(self,first)
            TYPEWRITER = makeType()
            if first ~= 'first' then
                TYPEWRITER:resume()
            end
            self.voidCircle = true
            self.safeWrite = true
            local delay1 = 0.5
            local delay2 = 0.5
            self.line_x2 = self.x + 25
            self.line_y2 = self.y + 25
            local line_x2_target = self.line_x2 + 55
            local line_y2_target = self.line_y2 + 55
            Timer.tween(delay1, self,{circle_opacity=self.circle_opacity_target})
            Timer.tween(delay1,self,{circle_r = self.circle_r_target},'out-cubic')
            Timer.tween(delay1,self,{circle_w = self.circle_w_target},'out-cubic')
            Timer.after(delay1, function()
                Timer.tween(delay2,self,{line_x2=line_x2_target})
                Timer.tween(delay2,self,{line_y2=line_y2_target})                
            end)
            Timer.after(delay1+delay2, function()
                self.safeWrite = false
                Timer.tween(1,self,{x=self.tw_x},'in-out-cubic')
            end)
        end,

        draw = function(self,x,y,scale)
            self.x = x or self.x
            self.y = y or self.y
            self.scale = scale or self.scale
            if self.safeWrite == false then
                self.line_x2 = self.x + 70
                self.line_y2 = self.y + 70
            end
            love.graphics.setColor(0.9,0.9,1,self.button_opacity)
            love.graphics.rectangle('fill',self.x,self.y,self.button_w,self.button_h)
            love.graphics.setColor(1,1,1,0.2)   -- was 0.4 opacity 
            love.graphics.draw(image,self.x,self.y,nil,self.scale)
            love.graphics.setLineWidth(self.circle_w)
            love.graphics.setColor(0.8,0.8,0.8,self.circle_opacity)
            love.graphics.circle('line', self.x+48,self.y+50,self.circle_r)
            love.graphics.line(self.x+25,self.y+25,self.line_x2, self.line_y2)
            love.graphics.setLineWidth(1)
        end
    }
end