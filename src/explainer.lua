local rubik = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',48)
local rubikL = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',96)
local rubikS = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',32)
local rubikXL = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',120)


function getArrow(sx,sy,ex,ey)
    -- get midpoint (mx,my): will be origin endpoint
    local mx = sx + (ex - sx) * 0.3 
    local my = sy + (ey - sy) * 0.3
    -- get origin coordinates
    local origin = getArrowCoords(sx,sy,mx,my)

    -- get target start point (tsx,tsy)
    local tsx = sx + (ex - sx) * 0.2 
    local tsy = sy + (ey - sy) * 0.2
    -- get target coordinates
    local target = getArrowCoords(tsx,tsy,ex,ey)

    -- get bounce coordinates
    local bsx = sx + (ex - sx) * 0.15
    local bsy = sy + (ey - sy) * 0.15
    local bex = sx + (ex - sx) * 0.85
    local bey = sy + (ey - sy) * 0.85

    local bounce = getArrowCoords(bsx,bsy,bex,bey)

    local coords = {}
    for i,v in ipairs(origin) do
        table.insert(coords, {val=v.val})
    end
    local opacity = 0
    local opacity_origin = 0
    local opacity_target1 = 1
    local opacity_target2 = 0.7

    return {
        origin = origin,
        target = target,
        coords = coords,
        opacity = opacity,
        bounce = bounce,
        opacity_origin = opacity_origin,
        opacity_target1 = opacity_target1,
        opacity_target2 = opacity_target2,

        open = function(self,delay)
            local delay = delay or 0.01
            local multiple = 1
            local delay1 = 0.5*multiple
            local delay2 = 0.4*multiple
            local delay3 = 0.3*multiple
            local mode = 'in-quad'
            Timer.after(delay, function()
                for i,v in ipairs(self.coords) do
                    Timer.tween(delay1,v,{val=self.target[i].val},'in-out-quad', function()
                        Timer.tween(delay2,v,{val=self.bounce[i].val},'in-out-quad', function()
                            Timer.tween(delay2,v,{val=self.target[i].val},'in-out-quad')
                        end)
                    end)
                end
                Timer.after(delay1+delay2+delay2, function()
                    for i,v in ipairs(self.coords) do
                        local delay = 0.05
                        local wait = 0.33
                        if i > 6 and i < 11 then
                            delay = 0.3
                            wait = 0.1
                        end
                        if i%2 == 0 then
                            Timer.after(wait, function()
                                Timer.tween(delay,v,{val=self.target[2].val},mode)
                            end)
                        else
                            Timer.after(wait, function()
                                Timer.tween(delay,v,{val=self.target[1].val},mode)
                            end)
                        end
                    end
                end)
                Timer.tween(delay1,self,{opacity=self.opacity_target1})
                Timer.after(0.8, function()
                    Timer.tween(delay2,self,{opacity=0.7})
                end)
                Timer.after(1.5+delay2, function()
                    Timer.tween(delay1,self,{opacity=0})
                end)

            end)
        end,

        draw = function(self,opacity)
            local opacity = opacity or self.opacity
            love.graphics.setColor(0.6,0,0,opacity)
            love.graphics.polygon('fill',self.coords[1].val,self.coords[2].val,self.coords[3].val,self.coords[4].val,self.coords[5].val,self.coords[6].val,self.coords[7].val,self.coords[8].val,self.coords[9].val,self.coords[10].val,self.coords[11].val,self.coords[12].val,self.coords[13].val,self.coords[14].val)
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

function getExplainerText(txts)
    local texts = {
        {
            txt = txts[1],
            font = rubikL,
            x = 0,
            x_target = 0 - (64/2)*0.1,
            y = 300 - 96/2,
            y_target = 300 - (96/2)*0.1,
            scale = 1,
        },
        {
            txt = txts[2],
            font = rubik,
            x = 0,
            x_target = 0 - (32/2)*0.1,
            y = 400,
            y_target = 400 + (48/2)*0.1,
            scale = 1,
        }
    }

    local txt = {opacity = 0}

    return {
        texts = texts,
        txt = txt,

        openText = function(self,cycles,delay)
            local delay = delay or 0.01
            local p_fast = 2
            local p_slow = 4
            Timer.after(delay,function()
                Timer.tween(p_fast,self.txt,{opacity=0.7},'in-out-cubic',function()
                    Timer.tween(p_fast,self.txt,{opacity=0},'in-out-cubic')
                end)
            end)
            return delay + p_slow
        end,

        draw = function(self)
            love.graphics.setColor(0.6,0,0,self.txt.opacity)
            for _,v in ipairs(self.texts) do
                love.graphics.printf(v.txt,v.font,0,v.y,800,'center',0,v.scale)
            end
        end
    }
end

function getScreen()
    local coords = {
        draw = {
            {val = 0},
            {val = 600},
            {val = 150},
            {val = 600},
            {val = 650},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 600}   
        },
        origin = {
            {val = 0},
            {val = 600},
            {val = 150},
            {val = 600},
            {val = 650},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 600}   
        },
        target1 = {
            {val = 0},
            {val = 0},
            {val = 130},
            {val = 0},
            {val = 650},
            {val = 0},
            {val = 800},
            {val = 0},
            {val = 800},
            {val = 150},
            {val = 800},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 130}
        },
        showTw ={
            {val = 130},
            {val = 130},
            {val = 130},
            {val = 0},
            {val = 650},
            {val = 0},
            {val = 800},
            {val = 0},
            {val = 800},
            {val = 150},
            {val = 800},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 130}
        },
        target2 = {
            {val = 800},
            {val = 0},
            {val = 800},
            {val = 130},
            {val = 800},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 150},
            {val = 0},
            {val = 0},
            {val = 150},
            {val = 0},
            {val = 670},
            {val = 0}
        },
        showMug = {
            {val = 670},
            {val = 130},
            {val = 800},
            {val = 130},
            {val = 800},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 150},
            {val = 0},
            {val = 0},
            {val = 150},
            {val = 0},
            {val = 670},
            {val = 0}
        },
        target3 = {
            {val = 800},
            {val = 600},
            {val = 725},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 0},
            {val = 650},
            {val = 0},
            {val = 800},
            {val = 0},
            {val = 800},
            {val = 150},
            {val = 800},
            {val = 525},
        },
        showInfo = {
            {val = 725},
            {val = 525},
            {val = 725},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 0},
            {val = 650},
            {val = 0},
            {val = 800},
            {val = 0},
            {val = 800},
            {val = 150},
            {val = 800},
            {val = 525},
        },
        rest = {
            {val = 800},
            {val = 600},
            {val = 725},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 0},
            {val = 600},
            {val = 650},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 800},
            {val = 600},
            {val = 800},
            {val = 600},
        }
    }

    local period = 0.2
    local onPeriod = 0.5
    local offPeriod = 0.3

    return {
        coords = coords,
        period = period,
        onPeriod = onPeriod,
        offPeriod = offPeriod,

        open = function(self)
            for i,v in ipairs(self.coords.draw) do 
                Timer.tween(self.onPeriod,v,{val=self.coords.target1[i].val},'in-out-cubic')
            end
            return self.onPeriod
        end,

        eExit = function(self)
            for i,v in ipairs(self.coords.draw) do 
                v.val = self.coords.target1[i].val
                Timer.tween(0.5,v,{val=self.coords.origin[i].val},'in-out-cubic')
            end
        end,

        close = function(self,delay)
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.offPeriod,v,{val=self.coords.rest[i].val},'in-out-cubic')
                end
            end)
            Timer.after(delay + self.offPeriod,function()
                for i,v in ipairs(self.coords.draw) do 
                    v.val=self.coords.origin[i].val
                end
            end)
            return self.onPeriod + delay
        end,

        showTw = function(self,delay)
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.period,v,{val=self.coords.showTw[i].val},'in-out-cubic')
                end
            end)
            return self.onPeriod
        end,

        hideTw =  function(self,delay)
            local delay = delay or 0.01
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.period,v,{val=self.coords.target1[i].val},'in-out-cubic')
                end
            end)
            Timer.after(delay + self.period,function()
                for i,v in ipairs(self.coords.draw) do 
                    v.val=self.coords.target2[i].val
                end
            end)
            return self.onPeriod
        end,

        showMug = function(self,delay)
            local delay = delay or 0.01
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.period,v,{val=self.coords.showMug[i].val},'in-out-cubic')
                end
            end)
            return self.onPeriod
        end,

        hideMug = function(self,delay)
            local delay = delay or 0.01
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.period,v,{val=self.coords.target2[i].val},'in-out-cubic')
                end
            end)
            Timer.after(delay + self.period,function()
                for i,v in ipairs(self.coords.draw) do 
                    v.val=self.coords.target3[i].val
                end
            end)
            return self.period
        end,

        showInfo = function(self,delay)
            local delay = delay or 0.01
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.period,v,{val=self.coords.showInfo[i].val},'in-out-cubic')
                end
            end)
            return self.onPeriod
        end,

        hideInfo = function(self,delay)
            local delay = delay or 0.01
            Timer.after(delay,function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.period,v,{val=self.coords.target3[i].val},'in-out-cubic')
                end
            end)
            Timer.after(delay + self.period,function()
                for i,v in ipairs(self.coords.draw) do 
                    v.val=self.coords.target3[i].val
                end
            end)
            return self.period
        end,

        draw = function(self)
            love.graphics.setColor(0.9,0.9,1,0.8)
            love.graphics.polygon('fill',self.coords.draw[1].val,self.coords.draw[2].val,self.coords.draw[3].val,self.coords.draw[4].val,self.coords.draw[5].val,self.coords.draw[6].val,self.coords.draw[7].val,self.coords.draw[8].val,self.coords.draw[9].val,self.coords.draw[10].val,self.coords.draw[11].val,self.coords.draw[12].val,self.coords.draw[13].val,self.coords.draw[14].val,self.coords.draw[15].val,self.coords.draw[16].val)
        end
    }

end

function explainIt()
    local screen = getScreen()
    local twArrow = getArrow(200,300,150,150)
    local mugArrow = getArrow(600,300,650,150)
    local infoArrow = getArrow(400,500,700,550)
    local texts = {
        {
            txts = {
                {
                    text = 'or',
                    font = rubik,
                    y = 200,
                    x = 0,
                    limit = 800
                },
                {
                    text = '[escape]',
                    font = rubikL,
                    y = 300 - 96/2,
                    x = 0,
                    limit = 800
                },
                {
                    text = 'to exit',
                    font = rubik,
                    y = 400,
                    x = 0,
                    limit = 800
                },
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = '[1]',
                    font = rubikL,
                    y = 225 - 96/2,
                    x = 0,
                    limit = 600
                },
                {
                    text = 'to break',
                    font = rubik,
                    y = 225,
                    x = 200,
                    limit = 600
                },
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = '[2]',
                    font = rubikL,
                    y = 375 - 96/2,
                    x = 0,
                    limit = 600
                },
                {
                    text = 'to skip',
                    font = rubik,
                    y = 375,
                    x = 200,
                    limit = 600
                },
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = 'or',
                    font = rubik,
                    y = 200,
                    x = 0,
                    limit = 800
                },
                {
                    text = '[backspace]',
                    font = rubikL,
                    y = 300 - 96/2,
                    x = 0,
                    limit = 800
                },
                {
                    text = 'for settings',
                    font = rubik,
                    y = 400,
                    x = 0,
                    limit = 800
                },
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = 'or [ i ] for info',
                    font = rubik,
                    y = 425,
                    x = 0,
                    limit = 400
                },
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = 'any other key\nto "type"',
                    font = rubik,
                    y = 300 - 48,
                    x = 0,
                    limit = 800
                }
            },
            opacity = 0
        }
    }
    local handles = {}

    return {
        screen = screen,
        twArrow = twArrow,
        mugArrow = mugArrow,
        texts = texts,
        infoArrow = infoArrow,
        handles = handles,

        open = function(self,key)
            local delay = 0.01
            delay = self.screen:open()
            self.twArrow:open(delay)
            self.screen:showTw(delay)
            delay = self:showText(delay+1,1)
            self.screen:hideTw(delay-0.5)
            self:showText(delay,2)
            delay = self:showText(delay+0.5,3)
            self.mugArrow:open(delay-0.5)
            self.screen:showMug(delay-0.5)
            delay = self:showText(delay,4)
            self.screen:hideMug(delay-0.5)
            self.infoArrow:open(delay)
            self.screen:showInfo(delay+0.1)
            delay = self:showText(delay+0.2,5)
            self.screen:hideInfo(delay-0.5)
            delay = self:showText(delay,6,4)
            delay = self.screen:close(delay-0.2)
            return delay
        end,

        showText = function(self,delay,index,delay2)
            local delay = delay or 0.1
            local delay2 = delay2 or 1.8
            local handle_1 = {}
            local handle_2 = {}
            local handle_3 = {}
            local handle_4 = {}
            handle_1 = Timer.after(delay,function()
                handle_2 = Timer.tween(0.2,self.texts[index],{opacity=0.7},'in-out-cubic')
                handle_3 = Timer.after(delay2,function()
                    handle_4 = Timer.tween(0.6,self.texts[index],{opacity=0},'in-cubic')
                end)
            end)
            table.insert(self.handles, handle_1)
            table.insert(self.handles, handle_2)
            table.insert(self.handles, handle_3)
            table.insert(self.handles, handle_4)
            return delay + delay2 + 0.8
        end,

        interrupt = function(self)
            for _,v in ipairs(self.handles) do
                Timer.cancel(v)
                v = {}
            end
            self.handles = {}
            for _,v in ipairs(self.texts) do
                Timer.tween(0.4,v,{opacity=0})
            end
            self.screen:eExit()
        end,

        showGif1 = function(self,delay)
            Timer.after(delay,function()
                Timer.tween(0.2,self,{gif_opacity=0.6})
                Timer.after(6,function()
                    Timer.tween(0.2,self,{gif_opacity=0})
                end)
            end)
        end,

        showGif2 = function(self,delay)
            Timer.after(delay,function()
                Timer.tween(0.2,self,{gif_opacity_2=0.6})
                Timer.after(6,function()
                    Timer.tween(0.2,self,{gif_opacity_2=0})
                end)
            end)
        end,

        draw = function(self)
            screen:draw()
            love.graphics.setColor(1,1,1,self.gif_opacity)
            love.graphics.setColor(1,1,1,self.gif_opacity_2)
            love.graphics.setColor(1,1,1)
            for _,v in ipairs(self.texts) do
                for j,w in ipairs(v.txts) do
                    love.graphics.setColor(0.6,0,0,v.opacity)
                    love.graphics.printf(w.text,w.font,w.x,w.y,w.limit,'center')
                end
            end
            self.twArrow:draw()
            self.mugArrow:draw()
            self.infoArrow:draw()
        end
    }
end

function miniExplain()
    local infoArrow = getArrow(400,500,700,550)
    local screen = {
        draw = {
            {val=0},
            {val=600},
            {val=0},
            {val=600},
            {val=400},
            {val=600},
            {val=400},
            {val=600}
        },
        origin = {
            {val=0},
            {val=600},
            {val=0},
            {val=600},
            {val=400},
            {val=600},
            {val=400},
            {val=600}
        },
        target1 = {
            {val=0},
            {val=600},
            {val=0},
            {val=420},
            {val=400},
            {val=420},
            {val=400},
            {val=600}
        },
        target2 = {
            {val=0},
            {val=500},
            {val=0},
            {val=420},
            {val=400},
            {val=420},
            {val=400},
            {val=500}
        },
    }
    local text = {
        text = 'or [ i ] for info',
        font = rubik,
        y = 425,
        x = 0,
        limit = 400,
        align = 'center',
        opacity = 0
    }

    return {
        screen = screen,
        text = text,
        infoArrow = infoArrow,

        open = function(self,delay)
            local delay = delay or 0.01
            Timer.after(delay,function()
                for i,v in ipairs(self.screen.draw) do
                    Timer.tween(0.2,v,{val=self.screen.target1[i].val},'in-cubic')
                end
                Timer.after(0.2,function()
                    for i,v in ipairs(self.screen.draw) do
                        Timer.tween(0.2,v,{val=self.screen.target2[i].val},'in-cubic')
                    end
                    self.infoArrow:open()
                    Timer.tween(0.2,self.text,{opacity=0.7},'in-cubic')
                    Timer.after(3,function()
                        Timer.tween(0.5,self.text,{opacity=0})
                    end)
                end)
                Timer.after(3.5,function()
                    for i,v in ipairs(self.screen.draw) do
                        Timer.tween(0.2,v,{val=self.screen.target1[i].val},'in-cubic')
                    end
                    Timer.after(0.2,function()
                        for i,v in ipairs(self.screen.draw) do
                            Timer.tween(0.2,v,{val=self.screen.origin[i].val},'in-cubic')
                        end
                    end)
                end)
            end)
        end,

        draw = function(self)
            love.graphics.setColor(0.9,0.9,1,0.8)
            love.graphics.polygon('fill',self.screen.draw[1].val,self.screen.draw[2].val,self.screen.draw[3].val,self.screen.draw[4].val,self.screen.draw[5].val,self.screen.draw[6].val,self.screen.draw[7].val,self.screen.draw[8].val)
            love.graphics.setColor(0.6,0,0,self.text.opacity)
            love.graphics.printf(self.text.text,self.text.font,self.text.x,self.text.y,self.text.limit,self.text.align)
            self.infoArrow:draw()
        end
    }
end

function explainSettings()
    local screen = getSettingsScreen()
    local jArrow = {}
    local kArrow = {}
    local lArrow = {}
    for i = 1, 3 do
        table.insert(jArrow, getArrow(350,150,350,50))
        table.insert(kArrow, getArrow(300,300,400,300))
        table.insert(lArrow, getArrow(350,450,350,550))
    end
    local uArrow1 = getArrow(250,150,0,150)
    local uArrow2 = getArrow(250,450,0,450)


    local texts = {
        {
            txts = {
                {
                    text = '[ j ]',
                    font = rubikXL,
                    y = 70 - 120/2,
                    x = 50,
                    limit = 300,  
                },
                {
                    text = 'to scroll up',
                    font = rubikS,
                    y = 150,
                    x = 50,
                    limit = 300,
                }
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = '[ k ]',
                    font = rubikXL,
                    y = 270 - 120/2,
                    x = 50,
                    limit = 300,  
                },
                {
                    text = 'to select',
                    font = rubikS,
                    y = 350,
                    x = 50,
                    limit = 300,
                }
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = '[ l ]',
                    font = rubikXL,
                    y = 470 - 156/2,
                    x = 50,
                    limit = 300,  
                },
                {
                    text = 'to scroll down',
                    font = rubikS,
                    y = 550,
                    x = 50,
                    limit = 300,
                }
            },
            opacity = 0
        },
        {
            txts = {
                {
                    text = '[ u ]',
                    font = rubikXL,
                    y = 270 - 120/2,
                    x = 50,
                    limit = 300,  
                },
                {
                    text = 'for back',
                    font = rubikS,
                    y = 350,
                    x = 50,
                    limit = 300,
                }
            },
            opacity = 0
        }
    }
    local handles = {}
    local arrow = {opacity=nil}

    return {
        jArrow = jArrow,
        kArrow = kArrow,
        lArrow = lArrow,
        uArrow1 = uArrow1,
        uArrow2 = uArrow2,
        texts = texts,
        screen = screen,
        handles = handles,
        arrow = arrow,

        open = function(self)
            local delay = 0.01
            local delay1 = 0.01
            delay = self.screen:open()
            for i = 1, 3 do
                self.jArrow[i]:open(delay+(i-1)*3)
                self.kArrow[i]:open(delay+(i-1)*3)
                self.lArrow[i]:open(delay+(i-1)*3)
            end
            for i = 1, 3 do
                delay1 = self:showText(delay,i)
            end
            local delay2 = self:showText(delay1,4)
            self.uArrow1:open(delay1+1)
            self.uArrow2:open(delay1+2)
            delay2 = self.screen:close(delay2)
        end,

        showText = function(self,delay, index)
            local delay = delay or 0.1
            local handle_1 = {}
            local handle_2 = {}
            local handle_3 = {}
            local handle_4 = {}
            handle_1 = Timer.after(delay,function()
                handle_2 = Timer.tween(0.2,self.texts[index],{opacity=0.7},'in-out-cubic')
                handle_3 = Timer.after(6.8,function()
                    handle_4 = Timer.tween(1.6,self.texts[index],{opacity=0},'in-cubic')
                end)
            end)
            table.insert(self.handles, handle_1)
            table.insert(self.handles, handle_2)
            table.insert(self.handles, handle_3)
            table.insert(self.handles, handle_4)
            return delay + 8.6
        end,

        interrupt = function(self)
            for _,v in ipairs(self.handles) do
                Timer.cancel(v)
                v = {}
            end
            self.handles = {}
            for _,v in ipairs(self.texts) do
                Timer.tween(0.4,v,{opacity=0})
            end
            self.screen:eExit()
            self.arrow.opacity = 0
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1)
            self.screen:draw()
            for i = 1, 3 do 
                self.jArrow[i]:draw(self.arrow.opacity)
                self.kArrow[i]:draw(self.arrow.opacity)
                self.lArrow[i]:draw(self.arrow.opacity)
            end
            self.uArrow1:draw(self.arrow.opacity)
            self.uArrow2:draw(self.arrow.opacity)
            love.graphics.setColor(1,1,1)
            for _,w in ipairs(self.texts) do
                for _,v in ipairs(w.txts) do
                    love.graphics.setColor(0.6,0,0,w.opacity)
                    love.graphics.printf(v.text,v.font,v.x,v.y,v.limit,'center')
                end
            end
        end

    }

end

function getSettingsScreen()
    local coords = {
        draw = {
            {val = 0},
            {val = 600},
            {val = 350},
            {val = 600},
            {val = 350},
            {val = 600},
            {val = 0},
            {val = 600},
        },
        origin = {
            {val = 0},
            {val = 600},
            {val = 350},
            {val = 600},
            {val = 350},
            {val = 600},
            {val = 0},
            {val = 600},
        },
        target = {
            {val = 0},
            {val = 0},
            {val = 350},
            {val = 0},
            {val = 350},
            {val = 600},
            {val = 0},
            {val = 600},
        },
    }

    local period = 0.2
    local onPeriod = 0.5
    local offPeriod = 0.3
    local handles = {}

    return {
        coords = coords,
        period = period,
        onPeriod = onPeriod,
        offPeriod = offPeriod,
        handles = handles,

        open = function(self)
            for i,v in ipairs(self.coords.draw) do 
                Timer.tween(self.onPeriod,v,{val=self.coords.target[i].val},'in-out-cubic')
            end
            return self.onPeriod
        end,

        close = function(self,delay)
            local delay = delay or 0.01
            local handle_1 = {}
            local handle_2 = {}
            Timer.after(delay, function()
                for i,v in ipairs(self.coords.draw) do 
                    Timer.tween(self.offPeriod,v,{val=self.coords.origin[i].val},'in-out-cubic')
                end
            end)
            table.insert(self.handles,handle_1)
            table.insert(self.handles,handle_2)
            return self.offPeriod
        end,

        eExit = function(self)
            for _,v in ipairs(self.handles) do
                Timer.cancel(v)
            end
            for i,v in ipairs(self.coords.draw) do 
                Timer.tween(0.3,v,{val=self.coords.origin[i].val},'in-out-cubic')
            end
        end,
        
        draw = function(self)
            love.graphics.setColor(0.9,0.9,1,0.8)
            love.graphics.polygon('fill',self.coords.draw[1].val,self.coords.draw[2].val,self.coords.draw[3].val,self.coords.draw[4].val,self.coords.draw[5].val,self.coords.draw[6].val,self.coords.draw[7].val,self.coords.draw[8].val)
        end

    }

end

