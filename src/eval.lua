PAPERS = {}
DEALER = {}
TRASHER = {}
GIF_AUX_SAVED = {}
GIF_AUX_SAVED_OPACITY = {val=1}
EVAL_RUMP = ''
EVAL_RUMP_ADD = false
EVAL_RUMP_ADDED = false

local evalTimer = require "libraries/hump/timer"

local paperTrashed = love.audio.newSource("assets/audio/paper_trashed_long.wav", "static")
local paperHit = love.audio.newSource("assets/audio/paper_trashed2.wav", "static")

local this1aGif = love.graphics.newImage('assets/spriteSheets/this1aNoMask.png')
local this2aGif = love.graphics.newImage('assets/spriteSheets/thisSheet2a.png')
local this3newGif = love.graphics.newImage('assets/spriteSheets/this3SheetNew.png')

local nopeGif = love.graphics.newImage('assets/spriteSheets/nopeSheet2.png')
local nope2Mob2Gif = love.graphics.newImage('assets/spriteSheets/nope2SheetMobile3.png')
local nope3Gif = love.graphics.newImage('assets/spriteSheets/nope3Sheet6.png')
   
local targetGif = love.graphics.newImage('assets/spriteSheets/targetSheet.png')
balledGif = love.graphics.newImage('assets/spriteSheets/crumpleSheet.png')
local balledGif2 = love.graphics.newImage('assets/spriteSheets/crumpleSheetAlpha.png')
local throwGif = love.graphics.newImage('assets/spriteSheets/throwSheet.png')

local animations = {}

--NoMask 240x240, x=0,y=-60
local this1aGrid = anim8.newGrid(240, 240, this1aGif:getWidth(), this1aGif:getHeight())
animations.this1a = anim8.newAnimation(this1aGrid('1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-5', 5, '1-5', 6, '1-5', 7, '1-5', 8, '1-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9, '3-3', 9), 0.1)
animations.this1aStill = anim8.newAnimation(this1aGrid('1-1',1),0.1)

-- Dimensions: 170x242  
-- Position: x = 0, y = 0 
-- Note: can pinch to x=0,y=-42; Dimensions: 125x158
local this2aGrid = anim8.newGrid(172, 240, this2aGif:getWidth(), 4800)
animations.this2a = anim8.newAnimation(this2aGrid('1-5', 1, '1-4', 2, '1-5', 3, '1-5', 4, '1-5', 5, '1-5', 6, '1-5', 7, '1-5', 8, '1-5', 9, '1-5', 10, '1-5', 11, '1-5', 12, '1-5', 13, '1-5', 14, '1-5', 15, '1-5', 16, '1-5', 17, '1-5', 18, '1-5', 19, '1-5', 20), 0.07)
animations.this2aStill = anim8.newAnimation(this2aGrid('1-1',1),0.1)

local this3newGrid = anim8.newGrid(154, 240, this3newGif:getWidth(), this3newGif:getHeight())
animations.this3new = anim8.newAnimation(this3newGrid('1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-5', 5, '1-5', 6, '1-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '5-5', 7, '1-5', 8, '1-5', 9, '1-5', 10, '1-5', 11, '1-5', 12, '1-5', 13, '1-5', 14, '1-5', 15, '1-5', 16, '1-5', 17, '1-5', 18, '1-5', 19, '1-3', 20),0.1)
animations.this3newStill = anim8.newAnimation(this3newGrid('1-1',1),0.1)

-- Dimensions: 160x240  
-- Position: x = -60, y = -5 
local nopeGrid = anim8.newGrid(428, 240, nopeGif:getWidth(), nopeGif:getHeight())
animations.nope = anim8.newAnimation(nopeGrid('1-5', 1, '1-5', 2, '1-5', 3, '5-5', 3, '5-5', 3, '5-5', 3, '5-5', 3, '5-5', 3, '5-5', 3, '5-5', 3), 0.1)
animations.nopeStill = anim8.newAnimation(nopeGrid('1-1',1),0.1)

-- Dimensions: 155x540  
-- Position: x = 0, y = 0
local nope2Mobile3Grid = anim8.newGrid(152, 540, nope2Mob2Gif:getWidth(), nope2Mob2Gif:getHeight())
animations.nope2Mob = anim8.newAnimation(nope2Mobile3Grid('1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-5', 5, '1-5', 6, '1-5', 7, '1-5', 8, '1-5', 9, '1-5', 10, '1-5', 11, '1-5', 12, '1-5', 13, '1-5', 14, '1-5', 15, '1-2', 16), 0.1)
animations.nope2Mob3Still = anim8.newAnimation(nope2Mobile3Grid('1-1',1),0.1)

-- Dimensions: 425x515  
-- Position: x = 0, y = 0
local nope3Grid = anim8.newGrid(421, 512, nope3Gif:getWidth(), nope3Gif:getHeight())
animations.nope3 = anim8.newAnimation(nope3Grid('1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-5', 5, '1-5', 6, '1-5', 7, '1-5', 8, '1-5', 9, '1-5', 10, '1-5', 11, '1-5', 12, '1-5', 13, '1-5', 14,'1-5', 15, '1-5', 16, '1-5', 17, '1-2', 18), 0.1)
animations.nope3Still = anim8.newAnimation(nope3Grid('1-1',1),0.1)

local balledGrid = anim8.newGrid(428, 240, balledGif:getWidth(), balledGif:getHeight())
animations.crumple = anim8.newAnimation(balledGrid('1-5', 1, '1-4', 2), 0.2)
animations.balled = anim8.newAnimation(balledGrid('1-3', 2), 0.05)

animations.balledFloor = {
    anim8.newAnimation(balledGrid('1-1', 2), 10),
    anim8.newAnimation(balledGrid('2-2', 2), 10),
    anim8.newAnimation(balledGrid('3-3', 2), 10)
}

local balledGrid2 = anim8.newGrid(320, 240, balledGif2:getWidth(), balledGif2:getHeight())
animations.crumple2 = anim8.newAnimation(balledGrid2('1-5', 1, '1-2', 2, '1-5', 2, '1-5', 3, '1-3', 4), 0.1)

local crumpleStills = {}
crumpleStills[1] = love.graphics.newImage('assets/sprites/crumpleStills/crumpleStill_1.png')
crumpleStills[2] = love.graphics.newImage('assets/sprites/crumpleStills/crumpleStill_2.png')
crumpleStills[3] = love.graphics.newImage('assets/sprites/crumpleStills/crumpleStill_3.png')
crumpleStills[4] = love.graphics.newImage('assets/sprites/crumpleStills/crumpleStill_4.png')

local throwGrid = anim8.newGrid(240, 240, throwGif:getWidth(), throwGif:getHeight())
animations.throw = {
    anim8.newAnimation(throwGrid('1-5', 1, '1-5', 2), 0.1),
    anim8.newAnimation(throwGrid('1-5', 2, '1-5', 1), 0.1),
    anim8.newAnimation(throwGrid('3-5', 1, '1-5', 2, '1-2', 1), 0.1),
    anim8.newAnimation(throwGrid('2-5', 2, '1-5', 1, '1-1', 2), 0.1)
}

local targetGrid = anim8.newGrid(428, 720, targetGif:getWidth(), targetGif:getHeight())
animations.target = anim8.newAnimation(targetGrid('1-5', 1), 0.2)

local gifs = {
    {name='this1a',x=2,y=-36,w=146,h=108,scale=0.6,x_turn=2,sprite=this1aGif,gif=animations.this1a,still=animations.this1aStill},
    {name='nope1',x=-48,y=-4,w=128,h=192,scale=0.8,x_turn=202,sprite=nopeGif,gif=animations.nope,still=animations.nopeStill,gif_origin=animations.nope},
    {name='this2a',x=0,y=-42,w=125,h=158,scale=1,x_turn=-42,sprite=this2aGif,gif=animations.this2a,still=animations.this2aStill},
    {name='nope2Mob',x=0,y=0,w=93,h=324,scale=0.6,x_turn=0,sprite=nope2Mob2Gif,gif=animations.nope2Mob,still=animations.nope2Mob3Still},
    {name='this3new',x=0,y=0,w=154,h=240,scale=1,x_turn=0,sprite=this3newGif,gif=animations.this3new,still=animations.this3newStill},
    {name='nope3',x=0,y=0,w=149,h=180,scale=0.35,x_turn=0,sprite=nope3Gif,gif=animations.nope3,still=animations.nope3Still}
}

local dealers = {

    function(words,chStart,w,text)            -- was fanShuffle
        local topBool = false
        local char = 10
        local len = 5
        local wordLen = len*char
        local char_h = 12
        local x = 650
        local y = 500 
        for i,v in ipairs(words) do
            v.x = x
            if i%2 == 0 then
                v.topBool = true
                v.y = y - char_h
            else
                v.y = y
            end
            v.ro = 0
        end
        local num = #words
        local opacity = 0
        local border_opacity = 0
        local border = {x=10, y=110, w=380, h=470}
        if chStart == 'no' then
            border.x = 410
        end
        local oldCards = {}
    
        return {
            words = words,
            char = char,
            char_h = char_h,
            len = len,
            wordLen = wordLen,
            x = x,
            y = y,
            num = num,
            opacity = opacity,
            border_opacity = border_opacity,
            border = border,
            oldCards = oldCards,

            appearSlow = function (self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(1,self,{opacity=1})
                end)
            end,
    
            appear = function (self,delay,period)
                local period = period or 0.2
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(period,self,{opacity=1})
                end)
            end,
    
            vanish = function (self,delay,period)
                local period = period or 0.2
                local delay = delay or 0.01
                evalTimer.after(delay,function()
                    evalTimer.tween(period,self,{opacity=0})
                    evalTimer.tween(period,self,{border_opacity=0})
                end)
            end,
    
            vanishSlow = function (self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay,function()
                    evalTimer.tween(1,self,{opacity=0})
                end)
            end,

            endPos = function(self)
                for _,v in ipairs(words) do 
                    v.y=v.y_end
                    v.x=v.x_end
                    v.ro=2*math.pi
                end
            end,
    
            fan = function(self,delay,periodFactor)
                local pF = periodFactor or 1
                local delay = delay or 0.05
                local delaySum = self.num*0.01+0.2+0.4+delay
                local sign = 1
                local yTargetTop = 0
                local yTargetNotTop = 0
                local yTarget2 = self.y
                local boost = 0
                evalTimer.after(delay, function()
                    for i,v in ipairs(self.words) do
                        if i > 10 then 
                            if v.topBool then
                                evalTimer.tween(0.08,v,{y=self.y-25},'in-quint')
                            else
                                evalTimer.tween(0.08,v,{y=self.y-25-self.char_h},'in-quint')
                            end
                        else
                            evalTimer.after((i-1)*0.01, function()
                                if v.topBool then
                                    evalTimer.tween(0.02,v,{y=self.y-25},'in-quint')
                                else
                                    evalTimer.tween(0.02,v,{y=self.y-25-self.char_h},'in-quint')
                                end
                            end)
                        end
                        evalTimer.after(0.1,function()
                            evalTimer.after((i-1)*0.01, function()
                                if v.topBool then
                                    yTargetTop = love.math.random(self.y,self.y+24)
                                    evalTimer.tween(0.02,v,{y=yTargetTop},'out-quint')
                                else
                                    yTargetNotTop = love.math.random(self.y-24,self.y)
                                    evalTimer.tween(0.2,v,{y=yTargetNotTop},'out-quint')
                                end
                            end)
                        end)
                    end
                    evalTimer.after(self.num*0.01+0.2,function()
                        for i,v in ipairs(self.words) do 
                            if v.topBool then
                                yTarget2Top = self.y+self.char_h/2
                                sign = -1
                                evalTimer.tween(0.4,v,{y=yTarget2Top},'in-out-cubic')
                                evalTimer.tween(0.4,v,{x=self.x+self.wordLen},'in-out-cubic')
                            else
                                yTarget2NotTop = self.y
                                sign = 1
                                evalTimer.tween(0.4,v,{y=yTarget2NotTop},'in-out-cubic')
                                evalTimer.tween(0.4,v,{x=self.x},'in-out-cubic')
                            end
                        end
                    end)
                end)
                return delaySum
            end,
    
            cut = function(self,delay,periodFactor)
                local periodFactor = periodFactor or 1
                local delay = delay or 0.05
                local delaySum = 1*periodFactor + delay
                evalTimer.after(delay, function()
                    for _,v in ipairs(self.words) do
                        if v.topBool then
                            evalTimer.tween(1*periodFactor,v,{x=v.x+(1.5*self.wordLen)+self.char},'in-out-cubic')
                            evalTimer.after(0.5*periodFactor, function()
                                evalTimer.tween(0.3*periodFactor,v,{y=self.y+self.char_h+8},'in-cubic')
                            end) 
                            evalTimer.tween(1*periodFactor,v,{ro=-math.pi},'in-out-cubic')
                        else
                            evalTimer.tween(1*periodFactor,v,{x=v.x-(0.5*self.wordLen)},'in-out-cubic')
                        end
                    end
                end)
                return delaySum
            end,
    
            cutFast = function(self,delay)
                local delay = delay or 0.05
                local delaySum = 0.5 + delay
                evalTimer.after(delay, function()
                    for _,v in ipairs(self.words) do
                        if v.topBool then
                            evalTimer.tween(0.5,v,{x=v.x+(1.5*self.wordLen)+self.char},'in-out-cubic')
                            evalTimer.after(0.25, function()
                                evalTimer.tween(0.15,v,{y=self.y+self.char_h+8},'in-cubic')
                            end) 
                            evalTimer.tween(0.5,v,{ro=-math.pi},'in-out-cubic')
                        else
                            evalTimer.tween(0.5,v,{x=v.x-(0.5*self.wordLen)},'in-out-cubic')
                        end
                    end
                end)
                return delaySum
            end,
    
            bridge = function(self,delay,periodFactor)
                local pF = periodFactor or 1
                local delay = delay or 0.01
                local delay1 = 0.3
                local sign = 1
                local delaySum = (0.01*self.num + 0.5)*pF + delay
                evalTimer.after(delay,function()
                    for i,v in ipairs(self.words) do
                        if v.topBool then
                            sign = -3
                            evalTimer.tween(delay1*pF,v,{x=v.x+(self.char/2)*sign},'in-out-cubic')
                            evalTimer.tween(delay1*pF,v,{ro=(math.pi/4)*sign},'in-out-cubic')
                        else
                            sign = -1
                            evalTimer.tween(delay1*pF,v,{x=v.x+(self.char/2)*sign},'in-out-cubic')
                            evalTimer.tween(delay1*pF,v,{ro=(math.pi/4)*sign},'in-out-cubic')
                        end
                        evalTimer.after(delay1*pF + 0.1*pF, function()
                            evalTimer.after((i-1)*0.01*pF, function()
                                if v.topBool then
                                    evalTimer.tween(0.05,v,{ro=-math.pi})
                                    evalTimer.tween(0.05,v,{x=v.x-self.char/2})
                                else
                                    evalTimer.tween(0.05,v,{ro=0})
                                    evalTimer.tween(0.05,v,{x=v.x+self.char/2})
                                end
                            end)
                        end)
                    end
                    evalTimer.after(delay1*pF + 0.1*pF, function()
                        for i,v in ipairs(self.words) do
                            if v.topBool then
                                evalTimer.tween(0.2*pF,v,{x=v.x-self.char/2},'in-out-quad')
                            else
                                evalTimer.tween(0.2*pF,v,{x=v.x+self.char/6},'in-out-quad')
    
                            end
                        end
                    end)
                end)
                return delaySum
            end,
    
            deal = function(self,delay,periodFactor)
                local pF = periodFactor or 1
                local delay = delay or 0.05
                local delaySum = delay + #words*0.02
                evalTimer.after(delay, function()
                    for i,v in ipairs(words) do
                        evalTimer.after((i-1)*0.02, function()
                            evalTimer.tween(0.1,v,{x=v.x_end})
                            evalTimer.tween(0.1,v,{y=v.y_end})
                            evalTimer.tween(0.1,v,{ro=2*math.pi})
                        end)
                    end
                    evalTimer.after(3,function()
                        evalTimer.tween(0.5,self,{border_opacity=1})
                    end)
                end)
                return delaySum
            end,

            storeIt = function(self)
                self.border_opacity = 0
            end,

            turnPage = function(self,period,delay)
                evalTimer.after(delay, function()
                    for _,v in ipairs(self.words) do
                        evalTimer.tween(period,v,{x=v.x_turn},'in-out-cubic')
                    end
                end)
            end,
    
            turned = function(self)
                for _,v in ipairs(self.words) do
                    v.x=v.x_turn
                end
            end,

            draw = function(self)
                love.graphics.setColor(0,0,0)
                love.graphics.setColor(0,0,0,self.opacity)
                love.graphics.setFont(FONT.courierS) 
                for i,v in ipairs(words) do
                    love.graphics.print(v.text,v.x,v.y,v.ro)
                end
            end
        }
    end,

    function(words,chStart,w,text)          -- was threeCardShuffle
        local char = 14
        local len = 5
        local wordLen = len*char
        local char_h = 18
        local x = 650
        local y = 500
        local random = {}
        for i,v in ipairs(words) do
            v.x = x
            v.ro = 0
            table.insert(random, love.math.random())
            if (i+2)%3 == 0 then
                v.one = true
                v.y = y
            elseif (i+1)%3 == 0 then
                v.two = true
                v.y = y - char_h
            elseif i%3 == 0 then
                v.three = true
                v.y = y - 2*char_h 
            end
        end

        local num = #words
        local opacity = 0
        local w = w or 'test'
        local sxStart = len/#w
        local word = {text=w,x=x,y=y-char_h,ro=0,sx=sxStart,sy=-1,opacity=0}
        local counter2 = 0
        local border = {x=10, y=110, w=380, h=470,opacity=0}
        if chStart == 'no' then
            border.x = 410
        end

        return {
            words = words, 
            char = char,
            char_h = char_h,
            len = len,
            wordLen = wordLen,
            x = x,
            y = y,
            num = num,
            opacity = opacity,
            random = random,
            --counter = counter,
            word = word,
            counter2 = counter2,
            sxStart = sxStart,
            border = border,

            appear = function (self,delay,period)
                self.counter2 = self.counter2 + 1
                local period = period or 0.2
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(period,self,{opacity=0.5})
                end)
            end,

            vanish = function (self,delay,period)
                local period = period or 2
                local delay = delay or 0.01
                evalTimer.after(delay,function()
                    evalTimer.tween(period,self,{opacity=0})
                    evalTimer.tween(period,self.border,{opacity=0})
                end)
            end,

            endPos = function(self)
                for _,v in ipairs(words) do 
                    v.y=v.y_end
                    v.x=v.x_end
                    v.ro=2*math.pi
                end
                self.word.opacity = 0
            end,

            showCard = function(self,delay,periodFactor,last)
                local pFraw = periodFactor or 1
                local pF = pFraw*1.5
                local delay = delay or 0.05
                local delaySum = delay + 3.7*pF +0.02
                evalTimer.after(delay, function()
                    evalTimer.tween(0.4*pF,word,{opacity=1},'out-quint')
                    evalTimer.tween(0.2*pF,word,{sx=1},'in-out-cubic')
                    evalTimer.tween(0.4*pF,word,{x=self.x-self.char},'in-out-cubic')
                    evalTimer.tween(0.4*pF,word,{ro=-1*(math.pi*0.2)},'in-out-cubic')
                    evalTimer.tween(0.4*pF,word,{y=self.y-4*self.char_h},'in-out-cubic')
                    evalTimer.after(0.8*pF,function()                       -- WAS 0.8
                        evalTimer.tween(0.2*pF,word,{sy=1})
                        evalTimer.tween(0.2*pF,word,{ro=-1*(math.pi*0.8)})
                        evalTimer.after(1*pF,function()
                            evalTimer.tween(0.2*pF,word,{sy=-1})
                            evalTimer.tween(0.2*pF,word,{y=word.y-self.char_h})
                            evalTimer.tween(0.2*pF,word,{x=word.x-self.char})
                            evalTimer.after(0.6*pF,function()
                                evalTimer.tween(0.2*pF,word,{sy=1})
                                evalTimer.tween(0.2*pF,word,{y=word.y+self.char_h})
                                evalTimer.tween(0.2*pF,word,{x=word.x+self.char})
                                evalTimer.tween(0.2*pF,word,{ro=-1*(math.pi*0.8)})
                            end)
                        end)
                    end)
                    evalTimer.after(3.2*pF,function()
                        evalTimer.tween(0.1*pF,word,{sy=-1})
                        evalTimer.tween(0.4*pF,word,{x=self.x},'in-out-cubic')
                        evalTimer.tween(0.4*pF,word,{ro=0},'in-out-cubic')
                        evalTimer.tween(0.4*pF,word,{y=self.y-self.char_h},'in-out-cubic')
                        evalTimer.tween(0.4*pF,word,{opacity=0})
                        evalTimer.after(0.2*pF,function()
                            evalTimer.tween(0.2*pF,word,{sx=self.sxStart},'in-out-cubic')
                        end)
                        evalTimer.after(0.5,function()
                            if last then
                                self:deal()
                            else
                                evalTimer.tween(0.5,self,{opacity=0})
                            end
                        end)
                    end)
                end)
                return delaySum
            end,

            mix = function(self,delay,periodFactor,func,last)
                local func = func or 'vanish'
                local pF = periodFactor or 1
                local delay = delay or 0.05
                local delaySum = delay + 2*pF +0.02
                if func == 'showCard' then
                    delaySum = delay + 2 +0.02 + (3.7*1.5*pF +0.02)*pF
                end
                evalTimer.after(delay,function()
                    self:appear(0.01,0.2)
                    for i,v in ipairs(self.words) do 
                        if v.three then 
                            evalTimer.tween(0.4*pF,v,{x=self.x-self.wordLen-self.char},'in-out-quad',function()
                                evalTimer.tween(0.2*pF,v,{y=self.y},'out-quint',function()
                                    evalTimer.after(0.4*pF,function()
                                        evalTimer.tween(0.4*pF,v,{x=self.x},'in-out-quad')
                                        evalTimer.after(0.2*pF,function()
                                            evalTimer.tween(0.2*pF,v,{y=self.y-self.random[i]*self.char_h},'in-out-quad',function()
                                                evalTimer.after(0.1*pF,function()
                                                    evalTimer.tween(0.3*pF,v,{y=self.y-(self.random[i]*self.char_h)-self.char})
                                                end)
                                            end)
                                        end)
                                    end)
                                end)
                            end)
                        elseif v.two then 
                            evalTimer.after(0.6*pF,function()
                                evalTimer.tween(0.4*pF,v,{x=x+self.wordLen+self.char},'in-out-quad',function()
                                    evalTimer.tween(0.2*pF,v,{y=self.y},'out-quint',function()
                                        evalTimer.after(0.01*pF,function()
                                            evalTimer.tween(0.4*pF,v,{x=self.x},'in-out-quad')
                                            evalTimer.after(0.3*pF,function()
                                                evalTimer.tween(0.1*pF,v,{y=self.y-self.random[i]*self.char_h},'in-out-quad')
                                            end)
                                        end)
                                    end)
                                end)
                            end)
                        else
                            evalTimer.after(1.2*pF,function()
                                evalTimer.tween(0.2*pF,v,{y=self.y-self.random[i]*self.char_h},'in-out-quad',function()
                                    evalTimer.after(0.01*pF,function()
                                        evalTimer.tween(0.2*pF,v,{y=self.y-self.random[i]*2*self.char_h},'in-out-quad')
                                    end)
                                end)
                            end)
                        end
                    end
                end)
                if func == 'vanish' then
                    evalTimer.after(1.2*pF,function()
                        self:vanish(delay,1)
                    end)
                elseif func == 'showCard' then
                    evalTimer.after(2*pF,function()
                        if last then
                            delay = self:showCard(delay,pF,last)
                        else
                            delay = self:showCard(delay,pF)
                        end
                    end)
                end

                return delaySum
            end,

            deal = function(self,delay,periodFactor)
                local pF = periodFactor or 1
                local delay = delay or 0.05
                local delaySum = delay + #words*0.02
                evalTimer.after(delay, function() 
                    evalTimer.tween(0.3*pF,self,{opacity=1})
                    for i,v in ipairs(words) do
                        evalTimer.after((i-1)*0.02*pF, function()
                            evalTimer.tween(0.1*pF,v,{x=v.x_end})
                            evalTimer.tween(0.1*pF,v,{y=v.y_end})
                            evalTimer.tween(0.1*pF,v,{ro=2*math.pi})
                        end)
                    end
                    evalTimer.after(2,function()
                        evalTimer.tween(0.2*pF,self.border,{opacity=1})
                    end)
                end)
                return delaySum
            end,

            storeIt = function(self)
                self.border.opacity = 0
            end,

            turnPage = function(self,period,delay)
                evalTimer.after(delay, function()
                    for _,v in ipairs(self.words) do
                        evalTimer.tween(period,v,{x=v.x_turn},'in-out-cubic')
                    end
                end)
            end,
    
            turned = function(self)
                for _,v in ipairs(self.words) do
                    v.x=v.x_turn
                end
            end,

            printSafe = function(self,v)
                love.graphics.print(v.text,v.x,v.y)
            end,

            draw = function(self)
                love.graphics.setColor(0,0,0,self.word.opacity)
                love.graphics.setFont(FONT.courierS) 
                love.graphics.print(self.word.text,self.word.x,self.word.y,self.word.ro,self.word.sx,self.word.sy)
                love.graphics.setColor(0,0,0,self.opacity)
                love.graphics.setFont(FONT.courierS) 
                for i,v in ipairs(words) do
                    love.graphics.print(v.text,v.x,v.y)
                end
            end
        }
    end,

    function (words,chStart,w,text)          -- was circleShuffle
        local char = 14
        local len = 5
        local wordLen = len*char
        local char_h = 18
        local x = 650
        local y = 500 
        for i,v in ipairs(words) do
            v.x = x
            v.x_target_1 = 800 + wordLen
            v.x_target_2 = math.floor(800 +wordLen - (400/#words)*((i-1)-#words)*-1)
            v.ro = 0
            v.ro_target_1 = (math.pi/4)*(((i-1)-#words)/#words)
            v.ro_target_2 = -1*(math.pi)+(math.pi/4)*(i/#words)
            v.y = y-((char_h/#words)*((i-1)-#words)*-1)
            v.opacity = 0
            v.sx = 1
            v.sy = 1
        end
        local realWords = {}
        for word in string.gmatch(text, "%S+") do
            table.insert(realWords, {text=word})
        end
        local sign = 1
        local step = 1
        local num = #words
        local refA = 0
        local radius = 50
        for i,v in ipairs(realWords) do 
            if i%2 == 0 then 
                sign = -1
            else
                sign = 1
                step = step + 1
            end
            v.x = x
            v.ro = -1*math.pi/2
            v.ro_origin = -1*math.pi/2
            v.ro_target = v.ro_origin + (sign*((2*math.pi)/#words)*step)
            if v.ro_target > 0 then
                --Q4
                refA = v.ro_target - 0
                v.x_plus = math.cos(refA)*radius
                v.y_plus = -1*math.sin(refA)*radius
            elseif v.ro_target > -math.pi/2 then
                --Q1
                refA = 0 - v.ro_target
                v.x_plus = math.cos(refA)*radius
                v.y_plus = math.sin(refA)*radius
            elseif v.ro_target > -math.pi then 
                --Q2
                refA = v.ro_target + math.pi
                v.x_plus = -1*math.cos(refA)*radius
                v.y_plus = math.sin(refA)*radius
            else
                --Q3
                refA = -1*(v.ro_target + math.pi)
                v.x_plus = -1*math.cos(refA)*radius
                v.y_plus = -1*math.sin(refA)*radius
            end
            v.y = y-3*char_h
            v.y_origin = y-3*char_h
            v.opacity = 0
        end
        local opacity = 0
        local border = {x=10, y=110, w=380, h=470}
        if chStart == 'no' then
            border.x = 410
        end
        
        return {
            words = words, 
            char = char,
            char_h = char_h,
            len = len,
            wordLen = wordLen,
            x = x,
            y = y,
            opacity = opacity,
            realWords = realWords,
            num = num,
            border = border,

            endPos = function(self)
                for _,v in ipairs(words) do 
                    v.y=v.y_end
                    v.x=v.x_end
                    v.ro=2*math.pi
                end
                for _,v in ipairs(realWords) do
                    v.opacity = 0
                end
            end,

            spread = function(self,delay,pF)
                pF = pF or 1
                local delay = delay or 0.01
                local delaySum = (0.6 + self.num*0.005 + 0.06)*pF + delay
                for i,v in ipairs(words) do
                    v.opacity = 1
                    evalTimer.tween(0.5*pF,v,{x=v.x_target_1},'in-out-quad',function()
                        evalTimer.after(0.1*pF, function()
                            evalTimer.tween((((i-1)-self.num)*-1)*0.005*pF,v,{x=v.x_target_2})
                            evalTimer.after((((i-1)-self.num)*-1)*0.005*pF,function()
                                evalTimer.tween(0.05*pF,v,{ro=v.ro_target_1})
                                evalTimer.tween(0.05*pF,v,{y=self.y})
                            end)
                        end)
                    end)
                end
                return delaySum
            end,

            ripple = function(self,delay,pF)
                pF = pF or 1
                delay = delay or 0.01
                local delaySum = delay + ((#words*0.0065) + 0.3)*2*pF +0.01
                evalTimer.after(delay+0.5, function()
                    for i,v in ipairs(self.words) do
                        evalTimer.after((((i-1)-#words)*-1)*0.005*pF,function()
                            evalTimer.tween(0.2*pF,v,{ro=v.ro_target_2},'in-out-quad')
                            evalTimer.tween(0.2*pF,v,{y=self.y+self.char_h*1.5},'in-out-quad')
                        end)
                        evalTimer.after(#words*0.007*pF,function()
                            evalTimer.after((i-1)*0.005*pF,function()
                                evalTimer.tween(0.2*pF,v,{ro=v.ro_target_1},'in-out-quad')
                                evalTimer.tween(0.2*pF,v,{y=self.y},'in-out-quad')
                            end)
                        end)
                    end
                end)
                return delaySum
            end,

            sweepUp = function(self,delay,pF)
                pF = pF or 1
                delay = delay or 0.01
                local delaySum = delay + (self.num*0.0085 + self.num*0.01) * pF + 0.01
                evalTimer.after(delay, function()
                    for i,v in ipairs(self.words) do
                        evalTimer.after((i-1)*0.0085*pF,function()
                            evalTimer.tween((((i-1)-#words)*-1)*0.01*pF,v,{x=v.x_target_1+300},'in-cubic')
                            evalTimer.tween((((i-1)-#words)*-1)*0.01*pF,v,{y=self.y-3*self.char_h},'in-quint')
                        end)
                    end
                end)
                evalTimer.after(delaySum,function()
                    for _,v in ipairs(self.words) do
                        v.opacity = 0
                    end
                    for _,v in ipairs(self.realWords) do
                        v.opacity = 0
                    end
                end)
                return delaySum
            end,

            circFan = function(self,delay)
                pF = pF or 1
                delay = delay or 0.01
                local delay2 = #self.realWords*0.005+0.5+#self.realWords*0.005+#self.realWords*0.002
                local delay3 = 0                        
                local delaySum = delay + delay2 + delay3           
                evalTimer.after(delay, function()
                    delay2 = self:wordFan(0.9)
                    for i,v in ipairs(self.words) do
                        v.opacity = 0
                        v.x = 650
                        v.y = self.y+50
                        v.ro = math.pi/2
                        evalTimer.tween(0.3*pF,v,{x=self.x},'in-out-cubic')
                        evalTimer.tween(0.3*pF,v,{y=self.y-50},'in-out-cubic')
                        evalTimer.tween(0.3*pF,v,{ro=-1*math.pi/2},'in-out-cubic')
                        evalTimer.tween(0.6*pF,v,{opacity=1},'out-quint')
                        evalTimer.after(0.5,function()
                            evalTimer.tween(0.3*pF,v,{y=self.y-30},'in-out-cubic',function()
                                evalTimer.tween(0.05*pF,v,{y=self.y-60},'in-out-cubic')
                                evalTimer.tween(0.1*pF,v,{opacity=0},'out-quint',function()
                                    v.y = self.y-100
                                end)
                                evalTimer.after((delay2),function()
                                    evalTimer.tween(0.2*pF,v,{opacity=1})
                                    evalTimer.after(0.5,function()
                                        evalTimer.tween(0.3*pF,v,{x=self.x},'in-out-cubic')
                                        evalTimer.tween(0.3*pF,v,{y=self.y},'in-out-cubic')
                                        evalTimer.tween(0.3*pF,v,{ro=0},'in-out-cubic',function()
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end
                end)
                delay3 = self:deal(delay + delay2 + 2)
                return delay3
            end,

            wordFan = function(self,delay)
                pF = pF or 1
                delay = delay or 0.01
                local delaySum = #self.realWords*0.005+0.5+#self.realWords*0.005+#self.realWords*0.002
                evalTimer.after(delay, function()
                    for j,w in ipairs(self.realWords) do
                        w.x = self.x
                        w.y = self.y-50
                        w.opacity = 0
                        evalTimer.tween(0.1*pF,w,{opacity=1},'in-quint')
                        evalTimer.tween(((j-1)*0.005)*pF,w,{ro=w.ro_target},'in-quint')
                        evalTimer.tween(((j-1)*0.005)*pF,w,{x=w.x+w.x_plus},'in-quint')
                        evalTimer.tween(((j-1)*0.005)*pF,w,{y=w.y-w.y_plus},'in-quint')
                        evalTimer.tween(((j-1)*0.01)*pF,w,{opacity=1},'in-quint')
                        evalTimer.after(#self.realWords*0.005+0.5,function()
                            evalTimer.tween(0.2*pF,w,{y=self.y-60-w.y_plus},'in-out-cubic',function()
                                evalTimer.tween(0.05*pF,w,{y=self.y-50-w.y_plus},'in-out-cubic')
                                evalTimer.after((((j-1)-#self.realWords)*-1)*0.005,function()
                                    evalTimer.tween(((((j-1)-#self.realWords)*-1)*0.002)*pF,w,{ro=w.ro_origin},'in-quint')
                                    evalTimer.tween(((((j-1)-#self.realWords)*-1)*0.002)*pF,w,{x=self.x},'in-quint')
                                    evalTimer.tween(((((j-1)-#self.realWords)*-1)*0.002)*pF,w,{y=self.y-100},'in-quint')
                                    evalTimer.tween(((((j-1)-#self.realWords)*-1)*0.002)*pF,w,{opacity=0},'in-quint')
                                end)
                            end)   
                        end)
                    end
                end)
                return delaySum
            end,

            deal = function(self,delay,periodFactor)
                local pF = periodFactor or 1
                local delay = delay or 0.05
                local delaySum = delay + #self.words*0.02
                evalTimer.after(delay, function() 
                    evalTimer.tween(0.3*pF,self,{opacity=1})
                    for i,v in ipairs(self.words) do
                        evalTimer.after((i-1)*0.02, function()
                            evalTimer.tween(0.1*pF,v,{x=v.x_end})
                            evalTimer.tween(0.1*pF,v,{y=v.y_end})
                            evalTimer.tween(0.1*pF,v,{ro=2*math.pi})
                        end)
                    end
                end)
                return delaySum
            end,

            storeIt = function(self)
                self.border_opacity = 0
            end,


            turnPage = function(self,period,delay)
                evalTimer.after(delay, function()
                    for _,v in ipairs(self.words) do
                        evalTimer.tween(period,v,{x=v.x_turn},'in-out-cubic')
                    end
                end)
            end,
            
            turned = function(self)
                for _,v in ipairs(self.words) do
                    v.x=v.x_turn
                end
            end,

            draw = function(self)
                love.graphics.setColor(0,0,0)
                love.graphics.setColor(0,0,0)
                love.graphics.setFont(FONT.courierS) 
                for i,v in ipairs(words) do
                    love.graphics.setColor(0,0,0,v.opacity)
                    love.graphics.print(v.text,v.x,v.y,v.ro,v.sx,v.sy)
                end
                for i,v in ipairs(realWords) do
                    love.graphics.setColor(0,0,0,v.opacity)
                    love.graphics.print(v.text,v.x,v.y,v.ro)
                end
            end
        }
    end
}

local shufflers = {

    function(text,pNum,chStart,gif,delay,gifAuxFlag,gifAux,bookmark,oldPage)         -- was fanShuffleRun
        local delay = delay or 0.01
        local delayPlus = 0.01
        local delaySum = 0
        local cards = {}
        local dealer = {}
        local overlap = 0
        local pF = 0.5
        local loops = 2
        if bookmark and bookmark > 0 then
            loops = 1
        end
        local gifReturn
        local cardsReturn
        local gifReturn1
        local storedCards = {}
        local placement = 0
        local oldCards = {}
        if oldPage and oldPage.dealer then
            local storedCardsCopy = {}
            for orig_key,orig_value in pairs(oldPage.storedCards) do
                storedCardsCopy[orig_key] = orig_value
            end
            cardsReturn,gifReturn,placement = getCards(text,pNum,chStart,oldPage.gif,gifAuxFlag,oldPage.savedPlacement)
            local partCards = {}
            partCards,oldCards = getPartialCards(cardsReturn,chStart,bookmark,oldPage.bookmark)
            table.insert(dealer, dealers[1](partCards))
            storedCards = storedCardsCopy
            gifReturn1 = oldPage.gif 
        else
            for i=1, loops do
                cardsReturn,gifReturn,placement = getCards(text,pNum,chStart,gif,gifAuxFlag,placement)
                if bookmark then
                    for orig_key,orig_value in pairs(cardsReturn) do
                        storedCards[orig_key] = orig_value
                    end
                    cardsReturn,oldCards = getPartialCards(cardsReturn,chStart,bookmark)
                end
                if i == 1 then
                    gifReturn1 = gifReturn
                end
                table.insert(cards,cardsReturn)
                table.insert(dealer,dealers[1](cards[i],w,text))
            end
            for i = 1, math.floor(#dealer/2) do
                local tmp = dealer[i]
                dealer[i] = dealer[#dealer - i + 1]
                dealer[#dealer - i + 1] = tmp
            end 
        end
        for i,v in ipairs(dealer) do
            if i == 1 then
                v:appear(0.2,1.5)
                delay = v:cut(delay+delayPlus,pF)
                delay = v:bridge(delay+delayPlus+0.1,pF) 
                delay = v:fan(delay+delayPlus,pF)
            else
                v:appear(delay-0.5,1)
                delay = v:cut(delay+delayPlus,0.5,pF)
                delay = v:bridge(delay+delayPlus,pF) 
                delay = v:fan(delay+delayPlus,pF)
            end
            if i < #dealer then
                v:vanish(delay-1,1)
            end
            delay = delay - 0.5
        end
        delay = dealer[#dealer]:deal(delay + 0.5)
        local gif_opacity = 0
        gif = gifReturn1
        if gifAux and gifAux.scale then
            local multiple = 1
            gifAux.scale = gifAux.scale * multiple
            gifAux.x = gifAux.x*multiple + 780 - gifAux.w*multiple
            gifAux.y = 120 + 4*22
        end
        local gifAux_opacity = 0
        local border_opacity = 0
        local sheet = {}
        if chStart ~= 'no' and pNum == 1 then
            sheet = {x=10,y=110,w=380,h=470,x_turn=10}
        else
            sheet = {x=410,y=110,w=380,h=470,x_turn=10}
        end
        local active = true
        local gifActive = false
        if oldPage and oldPage.dealer then
            gifActive = true
            gif_opacity = 1
            border_opacity = 1
        end
        local pageTurned = false
        local savedPlacement = placement
        local gifStill = {}
        for orig_key,orig_value in pairs(gif) do
            gifStill[orig_key] = orig_value
        end
        gifStill.gif = gifStill.still
        local gifStill_opacity = 0
        return {
            border_opacity = border_opacity,
            delay = delay,
            gif = gif,
            gif_opacity = gif_opacity,
            gifAux = gifAux,
            gifAux_opacity = gifAux_opacity,
            sheet = sheet,
            active = active,
            dealer = dealer,
            gifActive = gifActive,
            gifAuxFlag = gifAuxFlag,
            pageTurned = pageTurned,
            pNum = pNum,
            storedCards = storedCards,
            bookmark = bookmark,
            savedPlacement = savedPlacement,
            oldCards = oldCards,
            gifStill = gifStill,
            gifStill_opacity = gifStill_opacity,

            gifAppear = function(self,delay)
                local delay = delay or 0.01
                if self.gifAuxFlag == 1 then
                    if string.sub(self.gif.name,1,4) == 'this' then
                        self.gifActive = true
                        self.gif_opacity = 1
                    else
                        self:gifAuxWait(delay)
                    end
                else
                    evalTimer.after(delay, function()
                        evalTimer.tween(1,self,{gif_opacity=1},'in-out-cubic', function()
                            self.gifActive = true
                            evalTimer.tween(0.5,self,{border_opacity = 1},'in-out-cubic')
                        end)
                    end)
                end
            end,

            gifAuxWait = function(self,delay)
                self.gifStill_opacity = 1
                self.gif_opacity = 0
                evalTimer.after(3,function()
                    self.gifActive = true
                    Timer.tween(1,self,{gif_opacity = 1})
                end)

            end,

            gifAuxOpacitySlider = function(self,delay)
                local cycles = math.ceil((delay - 4)/2)
                evalTimer.after(2,function()
                    evalTimer.tween(2,self,{gif_opacity=0.1},'out-cubic')
                    evalTimer.after(2,function()
                        for i=1, cycles do
                            evalTimer.after((i-1)*2,function()
                                evalTimer.tween(1,self,{gif_opacity=0.3},'in-out-cubic',function()
                                    evalTimer.tween(1,self,{gif_opacity=0.1},'in-out-cubic')
                                end)
                            end)
                        end
                    end)
                end)
                evalTimer.after(2+4+cycles*2,function()
                    evalTimer.tween(1,self,{gif_opacity=1},'in-out-cubic')
                end)
            end,

            gifAuxAppear = function(self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(0.1,self,{gifAux_opacity=1},'in-out-cubic')
                end)
            end,
    
            gifVanish = function(self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(0.5,self,{gif_opacity=0},'in-quad')
                    evalTimer.tween(0.5,self,{gifAux_opacity=0},'in-quad')
                end)
            end,

            storeIt = function(self)
                if self.gifAux then
                    self.gifAux = {}
                end
                self.border_opacity = 1
                for _,v in ipairs(dealer) do 
                    v:storeIt()
                end

            end,

            endPos = function(self)
                for i,v in ipairs(self.dealer) do 
                    v:endPos()
                    if i == #self.dealer then
                        self.dealer[i].opacity = 1
                    else
                        self.dealer[i].opacity = 0
                    end
                end
            end,

            turnPage = function(self,period,delay)
                self.pageTurned = true
                for _,v in ipairs(dealer) do 
                    v:turnPage(period,delay)
                end
                evalTimer.after(delay, function()
                    evalTimer.tween(period,self.sheet,{x=self.sheet.x-400},'in-out-cubic')
                    evalTimer.tween(period,self.gif,{x=self.gif.x-400},'in-out-cubic')
                    if self.oldCards and self.oldCards[1] then
                        for _,v in ipairs(self.oldCards) do
                            evalTimer.tween(period,v,{x_end=v.x_turn},'in-out-cubic')
                        end
                    end
                end)
            end,

            turned = function(self)
                for _,v in ipairs(dealer) do 
                    v:turned()
                end
                self.sheet.x=self.sheet.x_turn
                self.gif.x=self.gif.x_turn
            end,

            sleep = function(self)
                self.active = false
            end,

            draw = function(self)
                love.graphics.setColor(1,1,1)
                love.graphics.rectangle('fill',self.sheet.x,self.sheet.y,self.sheet.w,self.sheet.h)
                if self.gifAux and self.gifAux.gif then
                    love.graphics.setColor(1,1,1,self.gifAux_opacity)
                    self.gifAux.gif:draw(self.gifAux.sprite, self.gifAux.x, self.gifAux.y, 0, self.gifAux.scale)
                end
                love.graphics.setColor(1,1,1,self.gifStill_opacity)
                self.gifStill.gif:draw(self.gifStill.sprite,self.gifStill.x,self.gifStill.y,0,self.gifStill.scale)
                love.graphics.setColor(0,0,0)
                for _,v in ipairs(dealer) do 
                    v:draw()
                end
                if self.oldCards and self.oldCards[1] then
                    love.graphics.setColor(0,0,0)
                    for _,v in ipairs(self.oldCards) do 
                        love.graphics.print(v.text,v.x_end,v.y_end)
                    end
                end
                --love.graphics.setColor(1,1,1)
                love.graphics.setColor(1,1,1,self.gif_opacity)
                self.gif.gif:draw(self.gif.sprite, self.gif.x, self.gif.y, 0, self.gif.scale)
                love.graphics.setColor(0.7,0.7,0.7,self.border_opacity)
                love.graphics.rectangle('line',self.sheet.x,self.sheet.y,self.sheet.w,self.sheet.h)
            end,
        }
    end,

    function(text,pNum,chStart,gif,delay,gifAuxFlag,gifAux)       -- was threeCardShuffleRun
        local delay = delay or 0.01
        local delayPlus = 0.01
        local delaySum = 0
        local cards = {}
        local dealer = {}
        local overlap = 0
        local pF = 0.5
        local w = 'a'
        for i in string.gmatch(text, "%S+") do
            if #i > #w then
                w = i
            end
        end
        local loops = 4
        local gifReturn
        local cardsReturn
        local gifReturn1
        local placement = 0
        for i=1, loops do
            cardsReturn,gifReturn,placement = getCards(text,pNum,chStart,gif,gifAuxFlag,placement)
            table.insert(cards,cardsReturn)
            table.insert(dealer,dealers[2](cards[i],chStart,w,text))
        end
        for i,v in ipairs(dealer) do
            if i%2 == 0 then
                if i == #dealer then
                    delay = v:mix(delay+delayPlus,pF,'showCard','last')
                else
                    delay = v:mix(delay+delayPlus,pF,'showCard')
                end
            else
                delay = v:mix(delay+delayPlus,pF)
            end
            delay = delay
        end
        local gif_opacity = 0
        gif = gifReturn
        if gifAux and gifAux.scale then
            local multiple = 2
            gifAux.scale = gifAux.scale * multiple
            gifAux.x = gifAux.x*multiple + 780 - gifAux.w*multiple
            gifAux.y = 120 + 4*22
        end
        local gifAux_opacity = 0
        local border_opacity = 0
        local sheet = {}
        if chStart ~= 'no' and pNum == 1 then
            sheet = {x=10,y=110,w=380,h=470,x_turn=10}
        else
            sheet = {x=410,y=110,w=380,h=470,x_turn=10}
        end
        local active = true
        local gifActive = false
        local counter = 0
        local gifStill_opacity = 0
        local pageTurned = false

        return {
            border_opacity = border_opacity,
            delay = delay,
            gif = gif,
            gif_opacity = gif_opacity,
            gifAux = gifAux,
            gifAux_opacity = gifAux_opacity,
            sheet = sheet,
            active = active,
            dealer = dealer,
            gifActive = gifActive,
            gifAuxFlag = gifAuxFlag,
            counter = counter,
            gifStill_opacity = gifStill_opacity,
            pageTurned = pageTurned,
    
            gifAppear = function(self,delay)
                local delay = delay or 0.01
                if self.gifAuxFlag == 1 then
                    self.gifActive = true
                    self.gifStill_opacity = 1
                    evalTimer.after(delay+1, function()
                        evalTimer.tween(0.5,self,{border_opacity = 1},'in-out-cubic')
                        evalTimer.tween(2,self,{gif_opacity=1},'out-cubic')
                        evalTimer.after(2,function()
                            self.gifStill_opacity = 0
                        end)
                    end)
                else
                    evalTimer.after(delay, function()
                        evalTimer.tween(1,self,{gif_opacity=1},'in-out-cubic', function()
                            self.gifActive = true
                            evalTimer.tween(0.5,self,{border_opacity = 1},'in-out-cubic')
                        end)
                    end)
                end
            end,

            gifAuxAppear = function(self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(0.1,self,{gifAux_opacity=1},'in-out-cubic')
                end)
            end,
    
            gifVanish = function(self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(0.5,self,{gif_opacity=0},'in-quad')
                end)
            end,

            storeIt = function(self)
                if self.gifAux then
                    self.gifAux = {}
                end
                self.border_opacity = 1
                for _,v in ipairs(dealer) do 
                    v:storeIt()
                end
            end,

            endPos = function(self)
                for i,v in ipairs(self.dealer) do 
                    v:endPos()
                    if i == #self.dealer then
                        self.dealer[i].opacity = 1
                    else
                        self.dealer[i].opacity = 0
                    end
                end
            end,

            turnPage = function(self,period,delay)
                self.pageTurned = true
                for _,v in ipairs(dealer) do 
                    v:turnPage(period,delay)
                end
                evalTimer.after(delay, function()
                    evalTimer.tween(period,self.sheet,{x=self.sheet.x-400},'in-out-cubic')
                    evalTimer.tween(period,self.gif,{x=self.gif.x-400},'in-out-cubic')
                end)
            end,

            turned = function(self)
                for _,v in ipairs(dealer) do 
                    v:turned()
                end
                self.sheet.x=self.sheet.x_turn
                self.gif.x=self.gif.x_turn
            end,

            sleep = function(self)
                self.active = false
            end,

            draw = function(self)
                love.graphics.setColor(1,1,1)
                love.graphics.rectangle('fill',self.sheet.x,self.sheet.y,self.sheet.w,self.sheet.h)
                if self.gifAux and self.gifAux.gif then
                    love.graphics.setColor(1,1,1,self.gifAux_opacity)
                    self.gifAux.gif:draw(self.gifAux.sprite, self.gifAux.x, self.gifAux.y, 0, self.gifAux.scale)
                end
                for i,v in ipairs(dealer) do 
                    v:draw()
                end
                love.graphics.setColor(1,1,1,self.gif_opacity)
                self.gif.gif:draw(self.gif.sprite, self.gif.x, self.gif.y, 0, self.gif.scale)
                love.graphics.setColor(1,1,1,self.gifStill_opacity)
                self.gif.still:draw(self.gif.sprite, self.gif.x, self.gif.y, 0, self.gif.scale)
                love.graphics.setColor(0.7,0.7,0.7,self.border_opacity)
                love.graphics.rectangle('line',self.sheet.x,self.sheet.y,self.sheet.w,self.sheet.h)
            end,
        }
    end,

    function(text,pNum,chStart,gif,delay,gifAuxFlag,gifAux)       -- was circleShuffleRun
        local delay = delay or 0.01
        local dealer = {}
        local placement = 0
        local cards,gifTrash,placement = getCards(text,pNum,chStart,gif,gifAuxFlag,placement)
        table.insert(dealer,dealers[3](cards,chStart,w,text))
        local cards2,gifReturn1 = getCards(text,pNum,chStart,gif,gifAuxFlag,placement)
        table.insert(dealer,dealers[3](cards2,chStart,w,text))
        delay = dealer[1]:spread(delay)
        delay = dealer[1]:ripple(delay)
        delay = dealer[1]:sweepUp(delay)
        local delayTrash = delay + 1
        delay = dealer[2]:circFan(delay-1)
        local gif_opacity = 0
        gif = gifReturn1
        local border_opacity = 0
        local sheet = {}
        if chStart ~= 'no' and pNum == 1 then
            sheet = {x=10,y=110,w=380,h=470,x_turn=10}
        else
            sheet = {x=410,y=110,w=380,h=470,x_turn=10}
        end
        local active = true

        evalTimer.after(delayTrash,function()
            dealer[1].opacity = 0
        end)
        local gifActive = false
        local pageTurned = false
        local lastPx = {x=cards2[#cards2].x_end+#cards2[#cards2].text*10,y_end=cards2[#cards2].x}

        return {
            border_opacity = border_opacity,
            delay = delay,
            gif = gif,
            gif_opacity = gif_opacity,
            sheet = sheet,
            dealer = dealer,
            active = active,
            gifActive = gifActive,
            pageTurned = pageTurned,
            pNum = pNum,
            gifAux = gifAux,
            gifAuxFlag = gifAuxFlag,
            placement = placement,
            lastPx = lastPx,

            gifAppear = function(self,delay)
                local delay = delay or 0.01
                if self.gifAuxFlag == 1 then
                    self:gifAuxOpacitySlider(delay)
                else
                    evalTimer.after(delay, function()
                        evalTimer.tween(1,self,{gif_opacity=1},'in-out-cubic', function()
                            self.gifActive = true
                            evalTimer.tween(0.5,self,{border_opacity = 1},'in-out-cubic')
                        end)
                    end)
                end
            end,

            gifAuxOpacitySlider = function(self,delay)
                local cycles = math.ceil((delay - 4)/2)
                evalTimer.after(2,function()
                    evalTimer.tween(2,self,{gif_opacity=0.1},'out-cubic')
                    evalTimer.after(2,function()
                        for i=1, cycles do
                            evalTimer.after((i-1)*2,function()
                                evalTimer.tween(1,self,{gif_opacity=0.3},'in-out-cubic',function()
                                    evalTimer.tween(1,self,{gif_opacity=0.1},'in-out-cubic')
                                end)
                            end)
                        end
                    end)
                end)
                evalTimer.after(2+4+cycles*2,function()
                    evalTimer.tween(1,GIF_AUX_SAVED_OPACITY,{val=1},'in-out-cubic')
                end)
            end,
    
            gifVanish = function(self,delay)
                local delay = delay or 0.01
                evalTimer.after(delay, function()
                    evalTimer.tween(0.5,self,{gif_opacity=0},'in-quad')
                end)
            end,

            storeIt = function(self)
                if self.gifAux then
                    self.gifAux = {}
                end
                self.border_opacity = 1
                for _,v in ipairs(dealer) do 
                    v:storeIt()
                end
            end,

            endPos = function(self)
                for i,v in ipairs(self.dealer) do 
                    v:endPos()
                    if i == #self.dealer then
                        self.dealer[i].opacity = 1
                    else
                        self.dealer[i].opacity = 0
                    end
                end
            end,

            turnPage = function(self,period,delay)
                self.pageTurned = true
                for _,v in ipairs(dealer) do 
                    v:turnPage(period,delay)
                end
                evalTimer.after(delay, function()
                    evalTimer.tween(period,self.sheet,{x=self.sheet.x-400},'in-out-cubic')
                    evalTimer.tween(period,self.gif,{x=self.gif.x-400},'in-out-cubic')
                end)
            end,

            turned = function(self)
                for _,v in ipairs(dealer) do 
                    v:turned()
                end
                self.sheet.x=self.sheet.x_turn
                self.gif.x=self.gif.x_turn
            end,

            sleep = function(self)
                self.active = false
            end,

            draw = function(self)
                love.graphics.setColor(1,1,1)
                love.graphics.rectangle('fill',self.sheet.x,self.sheet.y,self.sheet.w,self.sheet.h)
                for _,v in ipairs(dealer) do
                    v:draw()
                end
                love.graphics.setColor(1,1,1,self.gif_opacity)
                self.gif.gif:draw(self.gif.sprite, self.gif.x, self.gif.y, 0, self.gif.scale)

                love.graphics.setColor(0.7,0.7,0.7,self.border_opacity)
                love.graphics.rectangle('line',self.sheet.x,self.sheet.y,self.sheet.w,self.sheet.h)
            end
        }
    end
}

local counterEval = 0
local gifAuxDelay = 0

function evalUpdate(dt)
    counterEval = counterEval + 1
    evalTimer.update(dt*PREFS.speed*1.5)
    if BOOK and BOOK.twPagesF and BOOK.twPagesF[1] then 
        for _,v in ipairs(BOOK.twPagesF) do
            if v.active and v.gifActive then
                v.gif.gif:update(dt)
            end
            if v.gifAux and v.gifAux.gif and v.gifAux_opacity == 1 then
                gifAuxDelay = gifAuxDelay + 1
                if gifAuxDelay > 60 then
                    v.gifAux.gif:update(dt)
                end
            end
        end
    end
    if DEALER and DEALER.header and DEALER.header.button_n then
        DEALER.header:onHover(dt)
        DEALER.header:onHover(dt)
    end
    if TRASHER and TRASHER.balledData then
        animations.crumple:update(dt)
        animations.crumple2:update(dt*TRASHER.crumpleSpeed)
    end
    if TRASHER and TRASHER.targetGo then
        animations.target:update(dt)
        if TRASHER.target.x < 450 and TRASHER.target.x > -50 and TRASHER.targetGo then
            TRASHER.target.x = TRASHER.target.x + dt*70*TRASHER.target.var
        elseif TRASHER.target.x <= -50 then
            TRASHER.target.x = -49
            TRASHER.target.var = TRASHER.target.var * -1
        elseif TRASHER.target.x >= 450 then
            TRASHER.target.x = 449
            TRASHER.target.var = TRASHER.target.var * -1 
        end
    end
    for i,v in ipairs(PAPERS) do
        v.ani:update(dt*v.aniSpeed)   
    end
end

local gifAuxSaved_counter = 0
local state_counter = 0

local trash_count = 0
function drawEval()
    if DEALER and DEALER.page then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle('fill',0,0,800,600)
        love.graphics.setColor(0,0,0)
        if BOOK and BOOK.twPagesF and BOOK.twPagesF[1] then
            for i,v in ipairs(BOOK.twPagesF) do
                if v.active and i ~= #BOOK.twPagesF - 1 then
                    v:draw()
                end
            end
        end
    end

    if DEALER and DEALER.header and DEALER.header.draw then
        DEALER.header:draw()
    end
    if DEALER and DEALER.page then
        if BOOK and BOOK.twPagesF and BOOK.twPagesF[2] then
            BOOK.twPagesF[#BOOK.twPagesF-1]:draw()
        end
    end
    if TRASHER and TRASHER.draw then
        trash_count = trash_count + 1
        love.graphics.setColor(1,0,0)
        love.graphics.setColor(1,1,1)
        TRASHER:draw()
    end
    state_counter = state_counter + 1
end

function reopenChapter()

    local sheets = {}

    return {
        draw = function(self)
            for i,v in ipairs(BOOK.twPagesF) do
                love.graphics.setColor(1,1,1,self.opacity[i])
                v:draw()
            end
        end
    }
end

function partialPage(text,chStart)
    local oldPage = {}
    if BOOK.partialPage then 
        oldPage = BOOK.twPagesF[#BOOK.twPagesF]
    end
    local page = shufflers[4](text,oldPage)



end

-- DEALER = getEvalHeader() (called in typewriter)
function evalPageFormat(text,chStart,bookmark) 
    TYPEWRITER:clearTimer()
    local backPages = {}
    local storedCards = {}
    -- Get page number:
    local pNum = 1
    if BOOK.partialPage then
        pNum = #BOOK.twPagesF
    else
        pNum = #BOOK.twPagesF + 1
    end 
    -- Get gif
    local gifNum = pNum
    if pNum > 6 then
        gifNum = ((pNum - 1) % 6) + 1 
    end
    local gif = {}
    for orig_key,orig_value in pairs(gifs[gifNum]) do
        gif[orig_key] = orig_value
    end
    local turnDelay = 0.01
    local turnPeriod = 0
    if BOOK.pages then
        if #BOOK.pages == 1 then
            BOOK.pages[1]:endPos()
        else
            BOOK.pages[#BOOK.pages]:endPos()
        end
    end
    if BOOK.partialPage == false then 
        if BOOK.twPagesF and #BOOK.twPagesF > 1 then
            turnDelay = 0.5
            turnPeriod = 0.8
        end
        local turnDelayTotal = turnDelay + turnPeriod
        if #BOOK.twPagesF > 1 then
            BOOK.twPagesF[#BOOK.twPagesF]:turnPage(turnPeriod,turnDelay)
        end
        if BOOK.twPagesF then
            evalTimer.after(turnDelayTotal+0.1,function()
                for i,v in ipairs(BOOK.twPagesF) do 
                    if i < (#BOOK.twPagesF - 1) then
                        v:sleep()
                    end
                end
            end) 
        end
    end
    -- Get shuffler
    local sNum = pNum 
    if pNum > 3 then
        sNum = ((pNum - 1) % 3) + 1 
    end
    local gifAux = {}

    if pNum == 1 then
        if gifNum == 6 then 
            gifNum = 0
        end
        for orig_key,orig_value in pairs(gifs[gifNum+1]) do
            gifAux[orig_key] = orig_value
        end
    end
    local gifAuxFlag = 0
    if next(GIF_AUX_SAVED) ~= nil then
        gif = GIF_AUX_SAVED
        gifAuxFlag = 1
    end
    local oldPage = {}
    if BOOK.partialPage then
        oldPage = BOOK:updateIt()
        for orig_key,orig_value in pairs(oldPage.storedCards) do
            storedCards[orig_key] = orig_value
        end
        sNum = 1
    end
    if bookmark and bookmark > 0 then
        sNum = 1
    end
    local page = shufflers[sNum](text,pNum,chStart,gif,turnDelay,gifAuxFlag,gifAux,bookmark,oldPage)
    local delay = page.delay
    page:gifAppear(delay)
    BOOK:storeIt(page,bookmark)
    local header = getEvalHeader(bookmark,storedCards)
    header:appear(header.button_t,delay+1,0.4)
    header:appear(header.button_n,delay+1.3,0.4)
    header:appear(header.tip_t,delay+2,1)
    if page.gifAux and next(page.gifAux) ~= nil then
        page:gifAuxAppear(page.delay+1)
        local gifAuxCopy = {}
        for orig_key,orig_value in pairs(page.gifAux) do
            gifAuxCopy[orig_key] = orig_value
        end
        GIF_AUX_SAVED = gifAuxCopy
    end

    if BOOK.twPagesF and BOOK.twPagesF[1] then
        local i = #BOOK.twPagesF
        local v = BOOK.twPagesF[i]
        print(i,'v.gif.name',v.gif.name,'v.gif_opacity',v.gif_opacity,'v.gifAuxFlag',v.gifAuxFlag,'v.gif.x',v.gif.x,'v.gif.y',v.gif.y)
    end
    
    return {
        backPages = backPages,
        page = page,
        header = header,
        bookmark = bookmark,
    }
end

function getEvalHeader(bookmark,storedCards)
    local y_plus = 30
    local header = {text="Can't save it all",x=0,y=5,w=800,font=FONT.rubik,opacity=0}
    local button_t = {text="[T]his",x=250 ,y=50-y_plus, w=150, h=40,font=FONT.courierXL,opacity=0,button_opacity=0,button_x=323-(6*19)/2,button_y=48-y_plus,button_w=(6*19)+4,button_h=36}
    local button_n = {text="[N]ope",x=400 ,y=50-y_plus, w=150, h=40,font=FONT.courierXL,opacity=0,button_opacity=0,button_x=473-(6*19)/2,button_y=48-y_plus,button_w=(6*19)+4,button_h=36}
    local tip_t = {text="(next page in book)",x=250 ,y=85-y_plus+5, w=150,font=FONT.roboto,opacity=0}
    local tip_n = {text="(go to next book)",x=400 ,y=85-y_plus+5, w=150,font=FONT.roboto,opacity=0}
    return {
        header = header,
        button_n = button_n,
        button_t = button_t,
        tip_n = tip_n,
        tip_t = tip_t,
        partial = partial,

        appear = function(self,obj,delay,period)
            evalTimer.after(delay, function()
                evalTimer.tween(period,obj,{opacity=1})
            end)
        end,

        vanish = function(self,obj)
            evalTimer.tween(0.5,obj,{opacity=0})
        end,

        onHover = function(self, dt)
            local mxTemp, myTemp = love.mouse.getPosition()
            local mx = (mxTemp - LEFT_OFFSET)/DRAW_SCALE
            local my = (myTemp - TOP_OFFSET)/DRAW_SCALE
            if mx >= self.button_n.x and mx <= self.button_n.x + self.button_n.w then
                if my >= self.button_n.y and my <= self.button_n.y + self.button_n.h then
                    self.button_n.button_opacity = 0.2
                else
                    self.button_n.button_opacity = 0
                end
            else
                self.button_n.button_opacity = 0
            end
            if mx >= self.button_t.x and mx <= self.button_t.x + self.button_t.w then
                if my >= self.button_t.y and my <= self.button_t.y + self.button_t.h then
                    self.button_t.button_opacity = 0.2
                else
                    self.button_t.button_opacity = 0
                end
            else
                self.button_t.button_opacity = 0
            end
        end,

        onClick = function(self,mouse_x,mouse_y)
            if (mouse_x >= self.button_n.x) and (mouse_x <= self.button_n.x + self.button_n.w) then
                if (mouse_y >= self.button_n.y) and (mouse_y <= self.button_n.y + self.button_n.h) then
                    self:onPress('n')
                end
            elseif (mouse_x >= self.button_t.x) and (mouse_x <= self.button_t.x + self.button_t.w) then
                if (mouse_y >= self.button_t.y) and (mouse_y <= self.button_t.y + self.button_t.h) then
                    self:onPress('t')
                end
            end
        end,

        onPress = function(self,key)
            if key == 't' then
                if EVAL_RUMP_ADDED then 
                    EVAL_RUMP_ADDED = false 
                    EVAL_RUMP_ADD = true
                else
                    print('clear EVAL_RUMP')
                    EVAL_RUMP = ''
                    EVAL_RUMP_ADD = false
                end
                GAME_STATE = 1
                for _,v in ipairs(BOOK.twPagesF) do 
                    if not v.gifAux or next(v.gifAux) == nil then
                        GIF_AUX_SAVED = {}
                    end
                    if v.gifAux then
                        v.gifAux = {}
                    end
                    for _,w in ipairs(v.dealer) do
                        w.words.x = w.words.x_end 
                        w.words.y = w.words.y_end 
                        w.words.ro = 2*math.pi
                    end
                end
                evalTimer.clear()
                jumpIntoPlace()
                if storedCards then
                    BOOK:storeCards(storedCards)
                end
                TYPEWRITER:paperLoad(bookmark)
            elseif key == 'n' then
                local canvas = love.graphics.newCanvas()
                canvas:renderTo(drawAllTheThings) 
                evalTimer.after(1.5,function()
                    jumpIntoPlace()
                    GIF_AUX_SAVED = {}
                    TRASHER = trashIt(canvas)
                    TRASHER:crumple()
                    TYPEWRITER:bookmarkIt('twRemain')
                    getBook('reset')
                    TYPEWRITER:paperOff()
                    TYPEWRITER.newChapter = true
                end)
            end
        end,

        draw = function(self)
            love.graphics.setColor(0,0,0,self.button_n.button_opacity)
            love.graphics.rectangle('fill',self.button_n.button_x,self.button_n.button_y,self.button_n.button_w,self.button_n.button_h)
            love.graphics.setColor(0,0,0,self.button_t.button_opacity)
            love.graphics.rectangle('fill',self.button_t.button_x,self.button_t.button_y,self.button_t.button_w,self.button_t.button_h)
            love.graphics.setFont(self.button_t.font)
            love.graphics.setColor(0,0,0,self.button_t.opacity)
            love.graphics.printf(self.button_t.text,self.button_t.x,self.button_t.y,self.button_t.w,'center')
            love.graphics.setColor(0,0,0,self.button_n.opacity)
            love.graphics.printf(self.button_n.text,self.button_n.x,self.button_n.y,self.button_n.w,'center')
            love.graphics.setFont(self.tip_t.font)
            love.graphics.setColor(0.5,0.5,0.5,self.tip_t.opacity)
            love.graphics.printf(self.tip_t.text,self.tip_t.x,self.tip_t.y,self.tip_t.w,'center')
            love.graphics.printf(self.tip_n.text,self.tip_n.x,self.tip_n.y,self.tip_n.w,'center')
        end
    }
end

myCallbackFunc = function(imgData)
    IMG = love.graphics.newImage(imgData)
end


function jumpIntoPlace()
    BOOK.twPagesF[#BOOK.twPagesF].gif_opacity=1
    BOOK.twPagesF[#BOOK.twPagesF].gifActive = true
    BOOK.twPagesF[#BOOK.twPagesF].border_opacity = 1
    BOOK.twPagesF[#BOOK.twPagesF]:endPos()
    if #BOOK.twPagesF > 1 then
        BOOK.twPagesF[#BOOK.twPagesF-1]:turned()
    end
    for i,v in ipairs(BOOK.twPagesF[#BOOK.twPagesF].dealer) do
        if i == #BOOK.twPagesF[#BOOK.twPagesF].dealer then
            v.opacity = 1
            for j,w in ipairs(v.words) do
                w.opacity = 1
            end
        end
    end
end

local rubik = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',48)
local rubikL = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',96)

function trashIt(canvas)
    local frame_opacity = 1
    local balledData = {x = -1000, y = -600, r = 0, scale = 6,opacity=1}
    local targetGo = false
    local target = {x=math.random(1,450),var=1,opacity=1}
    local paper = {x = 0, y = 0, ro = 0, scale = 3, thrown = false, aniSpeed = 1, ani = animations.throw[1],flying = true,img=throwGif}
    local aim_x = 0
    local aim_y = 0
    local morePaper = false
    local tAdj = 1
    local crumpleSpeed = 0
    local texts = {
        {
            text = '[ j ]',
            x = 0,
            y = 400,
            font = rubikL,
            limit = 400,
            align = 'center',
            opacity = 0
        },
        {
            text = 'to throw',
            x = 0,
            y = 520,
            font = rubik,
            limit = 400,
            align = 'center',
            opacity = 0
        }
    }
    local screen = {
        draw = {
            {val=60},
            {val=600},
            {val=60},
            {val=600},
            {val=335},
            {val=600},
            {val=335},
            {val=600}
        },
        origin = {
            {val=60},
            {val=600},
            {val=60},
            {val=600},
            {val=335},
            {val=600},
            {val=335},
            {val=600}
        },
        target = {
            {val=60},
            {val=600},
            {val=60},
            {val=380},
            {val=335},
            {val=380},
            {val=335},
            {val=600}
        }
    }
    local crumpleStill = crumpleStills[1]

    return {
        balledData = balledData,
        targetGo = targetGo,
        target = target,
        paper = paper,
        aim_x = aim_x,
        aim_y = aim_y,
        morePaper = morePaper,
        tAdj = tAdj,
        canvas = canvas,
        frame_opacity = frame_opacity,
        crumpleSpeed = crumpleSpeed,
        texts = texts,
        screen = screen,
        crumpleStill = crumpleStill,

        crumple = function(self)
            DEALER = {}
            --self.crumpleSpeed = 1
            evalTimer.after(1,function()
                paperTrashed:play()            
            end)
            evalTimer.after(1.4,function()
                self.frame_opacity = 0
                self.crumpleStill = crumpleStills[2]
            end)
            evalTimer.after(1.8,function()
                self.crumpleStill = crumpleStills[3]
            end)
            evalTimer.after(2.2,function()
                self.crumpleStill = crumpleStills[4]
            end)
            evalTimer.after(2.5,function()
                self.balledData.opacity = 0
                self:startTarget()
                self:showText()
            end)
        end,

        showText = function(self,delay)
            local delay = delay or 0.01
            evalTimer.after(delay,function()
                for i,v in ipairs(self.screen.draw) do
                    evalTimer.tween(0.2,v,{val=self.screen.target[i].val},'in-cubic')
                end
                evalTimer.after(0.5, function()
                    for _,v in ipairs(self.texts) do
                        evalTimer.tween(0.2,v,{opacity=0.7},'in-cubic')
                        evalTimer.after(2,function()
                            evalTimer.tween(0.5,v,{opacity=0})
                        end)
                    end
                end)
                evalTimer.after(3.2,function()
                    for i,v in ipairs(self.screen.draw) do
                        evalTimer.tween(0.3,v,{val=self.screen.origin[i].val})
                    end
                
                end)
            end)
            return delay + 3.5
        end,

        onClick = function(self,mouse_x,mouse_y)
            if mouse_x >= 10 and mouse_x <= 780 then
                if mouse_y >= 330 then
                    self:throwPaper(mouse_x-320,mouse_y-150)
                end
            end 
        end,

        onPress = function(self,key)
            if key == 'j' then
               self:throwPaper(180 - math.floor(self.target.x), -100)
            end
        end,

        startTarget = function(self)
            self.targetGo = true
        end,

        stopTarget = function(self)
            self.targetGo = false
        end,

        throwPaper = function(self,x,y)
            self:stopTarget()
            self.paper.ani = animations.throw[math.random(1,4)]
            table.insert(PAPERS,self.paper)
            self.morePaper = true
            evalTimer.tween(0.6*self.tAdj,self.target,{opacity=0},'out-cubic')
            self.paper.thrown=true
            self.paper.aniSpeed = 5
            evalTimer.tween(0.6,self.paper,{aniSpeed=15},'in-cubic')
            evalTimer.tween(1.2*self.tAdj, self.paper, {scale = 0.15}, 'out-quint')
            evalTimer.tween(1.2*self.tAdj, self.paper, {x = x}, 'out-quint')
            evalTimer.tween(0.6*self.tAdj, self.paper, {y = y-70}, 'out-quint', function () 
                evalTimer.tween(0.6*self.tAdj, self.paper, {y = y-10}, 'in-quad') 
            end)
            evalTimer.after(1.3*self.tAdj, function()
                paperHit:play()
                self.paper.aniSpeed = 0
                self.paper.flying = false
                local diff = 0
                if self.paper.x > 210 then
                    diff = self.paper.x - 210
                end
                evalTimer.tween(1.4*self.tAdj, self.paper, {y = 40 + 0.8*diff}, 'in-quint', function()
                    evalTimer.after(0.1,function()
                        self.paper.aniSpeed = 2
                        self:paperFloor()
                    end)
                end)
            end)
        end,

        paperFloor = function(self)
            if self.paper.x < 120 or self.paper.x > 200 then
                local randomX = rng:random(-3, 3)
                local randomY = rng:random(0, 2)
                local restX = self.paper.x + 20*randomX
                if self.target.x > 200 and randomX < -1 then
                    randomY = randomY * -1
                end
                if restX < 120 then
                    restX = self.paper.x - 20*randomX
                elseif restX > 200 then
                    restX = self.paper.x + 20*randomX
                end
                local tempY = self.paper.y
                aniSpeed = 2
                local randomPeriod = math.floor(rng:random()*10)/10
                evalTimer.tween(0.2*self.tAdj+randomPeriod, self.paper, {x = restX}, 'out-quint')
                evalTimer.tween(0.2*self.tAdj+randomPeriod, self.paper, {y = tempY + 20*randomY}, 'out-quad', function()
                    self.paper.ani = animations.balledFloor[math.random(1,3)]
                    evalTimer.after(0.2, function()
                        GAME_STATE = 1
                        TYPEWRITER:paperLoad()
                        
                    end)
                end)
            else
                self.paper.ani = animations.balledFloor[math.random(1,3)]
                evalTimer.after(0.2, function()
                    GAME_STATE = 1
                    TYPEWRITER:paperLoad()
                end)
            end
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1,0.5)
            animations.target:draw(targetGif, 280 - self.target.x, -300)
            love.graphics.setColor(1,1,1,self.frame_opacity)
            love.graphics.draw(self.canvas)
            love.graphics.setColor(1,1,1,self.balledData.opacity)
            love.graphics.draw(self.crumpleStill, 0,0)
            --animations.crumple2:draw(balledGif2, 0,0,nil,2.5)
            love.graphics.setColor(0.9,0.9,1,0.8)
            love.graphics.polygon('fill',self.screen.draw[1].val,self.screen.draw[2].val,self.screen.draw[3].val,self.screen.draw[4].val,self.screen.draw[5].val,self.screen.draw[6].val,self.screen.draw[7].val,self.screen.draw[8].val)
            for _,v in ipairs(self.texts) do
                love.graphics.setColor(0.6,0,0,v.opacity)
                love.graphics.printf(v.text,v.font,v.x,v.y,v.limit,v.align)
            end
        end
    }
end

function getPartialCards(cards,chStart,end_bookmark,start_bookmark)
    local lastLine = false
    local lastChar = true
    local charCount = 0
    local cutoff = 0
    local cuton = 0
    local rump = 0
    local preRump = 0
    local goBool = true
    local startBool = false
    local end_bookmark = end_bookmark or 5000
    local start_bookmark = start_bookmark or 1
    local chBool = false
    if chStart ~= 'no' then
        end_bookmark = end_bookmark + 12
        chBool = true
    end
    for i,v in ipairs(cards) do
        if start_bookmark == 1 then
            startBool = true
            cuton = 1   
            preRump = 0   
        end
        charCount = charCount + #v.text
        if charCount > 12 and chBool then
            chBool = false 
            start_bookmark = start_bookmark + 12
        end
        if startBool == false and charCount > start_bookmark then
            startBool = true 
            cuton = i -1
            preRump = charCount - start_bookmark
        end
        if charCount > end_bookmark and goBool then
            cutoff = i - 1
            goBool = false
            rump = charCount - end_bookmark
        end
    end
    local preRumpString = ''
    local oldTopCard = {}
    local tempTopString = ''
    for orig_key,orig_value in pairs(cards[cuton]) do
        oldTopCard[orig_key] = orig_value
    end
    if preRump > 0 then
        local stringTable = {}
        for i = 1, #cards[cuton].text - preRump do
            table.insert(stringTable, ' ')
        end
        table.insert(stringTable,string.sub(cards[cuton].text, #cards[cuton].text - preRump + 1))
        tempTopString = string.sub(cards[cuton].text,1, #cards[cuton].text - preRump + 1)
        preRumpString = table.concat(stringTable,'')
        cards[cuton].text = preRumpString
    end
    oldTopCard.text = tempTopString
    local rumpString = ''
    if rump > 0 then
        rumpString = string.sub(cards[cutoff].text, 1, #cards[cutoff].text-rump)
        cards[cutoff].text = rumpString
    end
    if cutoff > 1 then
        for i = #cards, cutoff + 1, -1 do
            table.remove(cards,i)
        end
    end
    local oldCards = {}
    local tempCard = {}
    if cuton > 1 then
        for i = 1, cuton - 1 do
            tempCard = table.remove(cards,1)
            table.insert(oldCards,tempCard)
        end
    end
    table.insert(oldCards,oldTopCard)
--[[     for i,v in ipairs(cards) do
        print(i,v.text)
        for j,w in pairs(v) do 
            print(i,j,w) 
        end
    end ]]
    return cards,oldCards
end

function getCards(txt,pNum,chStart,gif,gifAuxFlag,prePlace,lastPx)
    local txt = txt
    if EVAL_RUMP_ADD then 
        txt = EVAL_RUMP..txt    
    end
    local gifAdj = {}
    for orig_key,orig_value in pairs(gif) do
        gifAdj[orig_key] = orig_value
    end
    gif = gifAdj
    local gifAuxTemp = {}
    for orig_key,orig_value in pairs(gif) do
        gifAuxTemp[orig_key] = orig_value
    end
    local char = 10
    local maxLinePx = 360
    local maxChar = math.floor(maxLinePx/char)
    local maxChar_base = maxChar
    local lineHeight = 22
    local x_start = 420
    local x_start_base = 420
    local y_start = 120
    local cutout_lines = math.ceil(gif.h/lineHeight)
    local cutout_maxChar = maxChar - math.ceil(gif.w/char)
    local placement = 0
    if gifAuxFlag == 1 and prePlace < 1 then
        placement = math.ceil((gif.y - y_start)/lineHeight)
    else
        if prePlace > 0 then
            placement = prePlace
        else
            placement = math.random(3,14-cutout_lines)
        end
    end
    local maxLines = 20
    if chStart ~= 'no' then
        maxLines = 14
        y_start = 250
        if pNum == 1 then
            x_start = 20
            x_start_base = 20
        end
        if prePlace < 1 then
            placement = math.random(3,10-cutout_lines)
        end
        gif.y = gif.y + y_start + placement*lineHeight
    else
        gif.y = gif.y + y_start + placement*lineHeight
    end
    local specifics = {}
    if string.sub(gif.name,1,4) == 'this' then
        for i = 1, (placement + cutout_lines -1) do
            if i < placement then
                table.insert(specifics, {maxChar=maxChar_base,x_start=x_start_base})
            else
                table.insert(specifics, {maxChar=cutout_maxChar,x_start=gif.w+x_start_base})
            end
        end
        gif.x = gif.x + x_start_base
        if chStart == 'no' then
            gif.x_turn = gif.x - 400
        else
            gif.x_turn = gif.x
        end
    else
        for i = 1, (placement + cutout_lines - 1) do
            if i < placement then
                table.insert(specifics, {maxChar=maxChar_base,x_start=x_start_base})
            else
                table.insert(specifics, {maxChar=cutout_maxChar,x_start=x_start_base})
            end
        end
        gif.x = gif.x + x_start_base + cutout_maxChar*char
        gif.x_turn = gif.x - 400
    end
    local x_pos = 0
    local spaces = {}
    local rawLine = ''
    local rawLineTemp = ''
    local remainingText
    local strTemp = ''
    local lastSpace = 0
    local word = ''
    local wordCount = 0
    local newLineBool = false
    local rump = ''
    local lines = 0
    local lastLine = false
    local noRemaining = false
    local words = {}
    local counter = 0
    local s = 0
    local s2 = 0
    local len = 5
    local realLastWord = ''
    local lastWord = ''
    local gifChanged = false
    local newLineBool2 = false
    if lastPx and lastPx.x and lastPx.x > 0 then
        x_start = lastPx.x
        y_start = lastPx.y
    end
    local tooBig = false
    while true do
        counter = counter +  1
        if specifics[lines] then 
            maxChar = specifics[lines].maxChar
            x_start = specifics[lines].x_start
        else
            maxChar = maxChar_base
            x_start = x_start_base
        end
        rawLine = string.sub(txt, 1, maxChar)
        remainingText = string.sub(txt, maxChar+1)
        if remainingText == '' then
            noRemaining = true
        end
        local n = string.find(rawLine, '\n\n')
        if n then
            strTemp = remainingText
            remainingText = ''
            if strTemp then
                remainingText = string.sub(rawLine, n+2)..strTemp
            else 
                remainingText = string.sub(rawLine, n+2)
            end
            rawLineTemp = string.sub(rawLine, 1, (n-1))
            rawLine = ''
            rawLine = rawLineTemp
            rawLineTemp = ''
            newLineBool = true
            newLineBool2 = true
        elseif noRemaining then
            lastLine = true
        else
            newLineBool = false
        end
        while true do
            s = string.find(rawLine, '%s',s+1)
            if s then
                table.insert(spaces,s)
            else
                break
            end
        end
        s = 0
        lastSpace = spaces[#spaces]                  
        if lastSpace then
            if lastSpace == 1 then
                break
            end
            wordCount = math.floor(lastSpace/len)
            lastWord = string.sub(rawLine, len*wordCount+1, lastSpace)
            if lastLine then
                realLastWord = string.sub(rawLine, lastSpace + 1)
            end
            rump = string.sub(rawLine, lastSpace+1)
            local _,z = string.find(rump, '%-')
            for i = 1, wordCount do
                word = string.sub(rawLine, 1,len)
                table.insert(words, {text=word,x_end=x_start+x_pos,y_end=y_start+lines*lineHeight,x_turn=x_start+x_pos})
                x_pos = x_pos + len*char
                rawLineTemp = string.sub(rawLine,len+1)
                rawLine = ''
                rawLine = rawLineTemp
                rawLineTemp = ''
            end
            x_pos = ((wordCount)*len)*char
            table.insert(words, {text=lastWord,x_end=x_start+x_pos,y_end=y_start+lines*lineHeight,x_turn=x_start+x_pos})
            if lastLine then
                x_pos = x_pos + (#lastWord)*char
                table.insert(words, {text=realLastWord,x_end=x_start+x_pos,y_end=y_start+lines*lineHeight,x_turn=x_start+x_pos})
            end
            if newLineBool then
                local rumpPlus = rump..'  '        
                table.insert(words,{text=rumpPlus,x_end=x_start+x_pos,y_end=y_start+lines*lineHeight,x_turn=x_start+x_pos})
            else
                if z and z > 0 and not lastLine then
                    local dashes = {}
                    s2=0
                    while true do
                        s2 = string.find(rump, '%-',s2+1)
                        if s2 then
                            table.insert(dashes,s2)
                        else
                            break
                        end
                    end
                    local lastDash = dashes[#dashes]
                    local wordCount2 = math.floor(lastDash/len)
                    local lastWord2 = string.sub(rump, len*wordCount2+1, lastDash)
                    local rump2 = string.sub(rump,lastDash+1)
                    local rumpTemp = ''
                    if lastWord then
                        x_pos = x_pos + #lastWord*char
                    end
                    for i = 1, wordCount2 do
                        word = string.sub(rump, 1,len)
                        table.insert(words, {text=word,x_end=x_start+x_pos,y_end=y_start+lines*lineHeight,x_turn=x_start+x_pos})
                        x_pos = x_pos + len*char
                        rumpTemp = string.sub(rump,len+1)
                        rump = ''
                        rump= rumpTemp
                        rumpTemp = ''
                    end
                    table.insert(words, {text=lastWord2,x_end=x_start+x_pos,y_end=y_start+lines*lineHeight,x_turn=x_start+x_pos})
                    rump = ''
                    rump = rump2
                end
                strTemp = rump..remainingText
                remainingText = ''
                remainingText = strTemp
                strTemp = ''
            end
            txt = ''
            txt = remainingText
            if text == '' then
                break
            end
            remainingText = ''
            if lastLine then
                break
            end
        else
            table.insert(words,{text=rawLine,x_end=x_start+x_pos*char,y_end=y_start+#lines*lineHeight,x_turn=x_start+x_pos})
        end
        x_pos = 1
        lines = lines + 1
        if lines > maxLines then 
            EVAL_RUMP_ADDED = true
            if string.sub(txt,1,1) == '%s' then
                EVAL_RUMP = string.sub(txt,2)
            else
                EVAL_RUMP = txt
            end
            if string.sub(EVAL_RUMP,#EVAL_RUMP,#EVAL_RUMP) ~= ' ' then
                local tempRump = EVAL_RUMP..' ' 
                EVAL_RUMP = ''
                EVAL_RUMP = tempRump 
            end
            tooBig = true
        end
        if tooBig then 
            break
        end
    end
    if chStart ~= 'no' then
        x_pos = maxLinePx/2 - (#chStart/2)*char
        wordCount = math.floor(#chStart/len)
        local rawLine = chStart
        for i = 1, wordCount do
            word = string.sub(rawLine, 1,len)
            table.insert(words, i, {text=word,x_end=x_start+x_pos,y_end=y_start-2*lineHeight,x_turn=x_start+x_pos})
            x_pos = x_pos + len*char
            rawLineTemp = string.sub(rawLine,len+1)
            rawLine = ''
            rawLine = rawLineTemp
            rawLineTemp = ''
        end
        if rawLine ~= '' then
            x_pos = x_pos
            table.insert(words, wordCount+ 1, {text=rawLine,x_end=x_start+x_pos,y_end=y_start-2*lineHeight,x_turn=x_start+x_pos})
        end
    end
    for _,w in ipairs(words) do
        if w.x_end > 400 then
            w.x_turn = w.x_end - 400
        end
    end
    if gifAuxFlag == 1 then
        gif = gifAuxTemp
    end
    return words,gif,placement 
end