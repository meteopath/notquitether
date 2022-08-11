TYPEWRITER = {}
local newPageTimer = require "libraries/hump/timer"
local typeTimer = require "libraries/hump/timer"

local tw = {
    body = love.graphics.newImage('assets/sprites/typewriter/body.png'),
    gate = love.graphics.newImage('assets/sprites/typewriter/gate.png'),
    handle_push = love.graphics.newImage('assets/sprites/typewriter/handle_push.png'),
    handle_rest = love.graphics.newImage('assets/sprites/typewriter/handle_rest.png'),
    roll = love.graphics.newImage('assets/sprites/typewriter/roll.png'),
    hammer_l = love.graphics.newImage('assets/sprites/typewriter/hammer_l.png'),
    hammer_lm = love.graphics.newImage('assets/sprites/typewriter/hammer_lm.png'),
    hammer_m = love.graphics.newImage('assets/sprites/typewriter/hammer_m.png'),
    hammer_rm = love.graphics.newImage('assets/sprites/typewriter/hammer_rm.png'),
    hammer_r = love.graphics.newImage('assets/sprites/typewriter/hammer_r.png'),
    hammer_down = love.graphics.newImage('assets/sprites/typewriter/slug.png')
}

local room = {
    room = love.graphics.newImage('assets/sprites/room/room_green_2.png'),
    trash_front = love.graphics.newImage('assets/sprites/room/trash_front.png'),
    trash_back = love.graphics.newImage('assets/sprites/room/trash_back.png'),
    carpet_slice = love.graphics.newImage('assets/sprites/room/carpet_slice2.png')
}

local sounds = {
    title = love.audio.newSource("assets/audio/title_audio.wav", "static"),
    roller1 = love.audio.newSource("assets/audio/roller_1.wav", "static"),
    roller_slow = love.audio.newSource("assets/audio/roller_slow.wav", "static"),
    carriage_return_long = love.audio.newSource("assets/audio/carriage_return_long.wav", "static"),
    carriage_return_short = love.audio.newSource("assets/audio/carriage_return_short.wav", "static"),
    key_space = love.audio.newSource("assets/audio/key_space.wav", "static"),
    key_space2 = love.audio.newSource("assets/audio/key_space2.wav", "static"),
    key1 = love.audio.newSource("assets/audio/key1.wav", "static"),
    key2 = love.audio.newSource("assets/audio/key2.wav", "static"),
    key3 = love.audio.newSource("assets/audio/key3.wav", "static"),
    key4 = love.audio.newSource("assets/audio/key4.wav", "static"),
    key5 = love.audio.newSource("assets/audio/key5.wav", "static"),
    bell = love.audio.newSource("assets/audio/bell.wav", "static"),
    paperHit = love.audio.newSource("assets/audio/paper_trashed2.wav", "static"),
    paperTrashed = love.audio.newSource("assets/audio/paper_trashed_long.wav", "static"),
    roller_double = love.audio.newSource("assets/audio/roller_double2.wav", "static"),
    paper_removed = love.audio.newSource("assets/audio/paper_removed.wav", "static"),
    paper = love.audio.newSource("assets/audio/paper.wav", "static"),
    gateSnapDown = love.audio.newSource("assets/audio/insert_snap.wav", "static"),
    gateSnapUp = love.audio.newSource("assets/audio/remove_snap.wav", "static")
}

for i, v in pairs(sounds) do 
    v:setVolume(0.4)
end
sounds.roller_double:setVolume(0.1)
sounds.roller1:setVolume(1)

local countWait = 1
local slugNumber = 0
function typewriterUpdate(dt)
    typeTimer.update(dt*1.5*PREFS.speed)
    if TYPEWRITER and TYPEWRITER.randomSlug and TYPEWRITER.randomSlug[1] then
        if TYPEWRITER.lineReady then
            TYPEWRITER:type()
        end
    end
    if TYPEWRITER and TYPEWRITER.randomSlug then
        if #TYPEWRITER.randomSlug == slugNumber then
            countWait = countWait + 1
        else
            countWait = 1
            slugNumber = #TYPEWRITER.randomSlug
        end
    end
    if TYPEWRITER and TYPEWRITER.explainerButton then
        TYPEWRITER.explainerButton:onHover(dt)
    end
end

function drawTypewriter()
    TYPEWRITER:draw()
    love.graphics.setColor(1,0,0)
end

function makeType()
    local x_adj = -150
    local y_adj = 0

    -- sprites
    local slugs = {tw.hammer_l,tw.hammer_lm,tw.hammer_m,tw.hammer_rm,tw.hammer_r,tw.hammer_down,tw.hammer_down}
    local slug_opacity = {0.3,0.3,0.3,0.3,0.3,0.7,0}
    local slug = 7
    local lastSlug = 7
    local sScale = 1.3
    local sY = 250
    local slug_x = {280,350,400,430,460,393,0}
    local slug_y = {sY,sY,sY,sY,sY,329,0}
    local slug_scale = {sScale,sScale,sScale,sScale,sScale,1,0}

    -- positions for sprites/paper/masks/tape
    local line_height = 48 
    local gate = {
        x = x_adj,
        y = y_adj,
        y_pos = 0,
        y_down = 0,
        y_up = 480,
        gateUp = false,
        sy = 1
    }
    local handle_x = x_adj - 100
    local handle_y = y_adj
    local handlePush = false
    local tape = {
        y_rest = 380,
        y_type = 335,
        x = 200,
        y = 380,
        w = 400,
        h = 25
    }
    local mask = {
        x_intro = 250,
        x_type = 385,
        x = 385,
        y_origin = 330,
        y = 330,
        w = 400,
        h = 42,
        opacity = 1,
        y_load = 495
    }

    local font = TT2020E
    local pages = {}
    local text = {
        x = 95,
        y = 335,
        y_origin = 335,
        y_saved = 335,
        y_overrun = 100,
        load_y_target_2 = 235,
        load_y_target_1 = 335,
        topMargin = 100,
        opacity = 0,
        y_load = 500
    }
    local paper = {
        x = -5,
        y = 0,
        w = 810,
        h = 420 + 10*line_height,
        h_end = 280,
        y_saved = 400,
        y_origin = 200,
        y_insert_origin = 400,
        load_y_target_2 = 135,
        load_y_target_1 = 235,
        y_load = 400,
        opacity = 1
    }
    local roll = {x=x_adj,y=y_adj,scale=1}
    local body = {x=x_adj,y=y_adj}
    
    local paper_insert = {
        y = 0,
        y_origin = 0,
        y_target = 150,
        h_origin = 0,
        h = 0,
        h_target = 400,
        y_insert_origin = 400
    }

    -- adj for sync moves
    local x_plus = 0            -- 0 is center
    local x_plus_start = 300
    local x_plus_min = -300
    local y_plus = 0

    -- For typing
    local randomSlug = {}
    local randomSound = {}
    local tab_target = 20
    local tab = 20
    local typeReady = true
    local charPx = 15
    local lineCount = 1
    local lineLength = 0
    local pageCount = 1
    local newPage = false
    local newChapter = false
    local intro = {
        y_origin = 330,
        y = 330,
        y_plus = 70,
        opacity_target = 0.7,
        first = true,
        set = {{text = 'I can do this.', opacity = 0},{text = 'From the top.', opacity = 0}},
        bool = true
    }
    local header_opacity = 0
    local lineReady = false
    local lineCursor = 0

    local header =  {'one','two','three','four','five','six','seven','eight','nine','ten','eleven','twleve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty','twenty-one','twenty-two','twenty-three','twenty-four','twenty-five','twenty-six','twenty-seven','twenty-eight','twenty-nine','thirty','thirty-one','thirty-two','thirty-three','thirty-four','thirty-five','thirty-six','thirty-seven','thirty-eight','thirty-nine','forty','forty-one','forty-two','forty-three','forty-four','forty-five','forty-six','forty-seven','forty-eight','forty-nine','fifty'}

    local needNextChapter = false
    local chapter = 0
    local test = 0
    local bell = false
    local lastLine = false
    local type_speed = 75

    local twIcon = getTwIcon(60,45,0.3)

    local concatText = ''

    local arm_down = {
        {220,500,398,362},
        {280,545,398,362},
        {400,560,398,362},
        {520,545,398,362},
        {580,500,398,362},
        {-1,-1,-1,-1},
        {-1,-1,-1,-1}
    }

    local arm_up = {
        {220,500,340,330},
        {280,545,370,345},
        {400,560,398,362},
        {520,545,428,345},
        {580,500,458,330},
        {-1,-1,-1,-1},
        {-1,-1,-1,-1}
    }

    local paper_y_origin = 200
    local newBookBool = false
    local addSlugReady = true
    local firstIntro = true
    local counter = 0
    local bookmark1 = 0
    local bookmark2 = 0
    local resume_bool = false
    local bookmark_x = 0
    local chAdd = {y=0}
    local explainerButton = getInfoButton(DRAW_WIDTH*0.95,DRAW_HEIGHT*0.965,24,COLORS.crimson,{},'explainer')
    explainerButton:open()
    local inactive = false
    local mExplain = {}

    return {
        handle_rest = tw.handle_rest,
        handle_push = tw.handle_push,
        handle = tw.handle_rest,
        slugs = slugs,
        slug_x = slug_x,
        slug_y = slug_y,
        slug_scale = slug_scale,

        -- positions
        gate = gate,             
        handle_x = handle_x,
        handle_y = handle_y,
        handlePush = handlePush,
        tape = tape,             
        mask = mask,
        font = font,
        text = text,
        line_height = line_height,
        paper = paper,
        roll = roll,
        body = body,
        paper_insert = paper_insert,
        addSlugReady = addSlugReady,

        -- adj for sync moves
        x_plus = x_plus,
        x_plus_start = x_plus_start,
        y_plus = y_plus,

        -- text
        lines = lines,

        -- typing
        randomSlug = randomSlug,
        randomSound = randomSound,
        tab = tab,
        tab_target = tab_target,
        typeReady = typeReady,
        slug = slug,
        slug_opacity = slug_opacity,
        slug_opacity_target_1 = slug_opacity_target_1,
        slug_opacity_target_2 = slug_opacity_target_2,
        charPx = charPx,
        lineCount = lineCount,
        lineLength = lineLength,
        pageCount = pageCount,
        newPage = newPage,
        newChapter = newChapter,
        pages = pages,
        header_opacity = header_opacity,
        header = header,
        needNextChapter = needNextChapter,
        lineReady = lineReady,
        introBool = introBool,
        lineCursor = lineCursor,
        x_plus_min = x_plus_min,
        test = test,
        bell = bell,
        lastLine = lastLine,
        type_speed = type_speed,
        twIcon = twIcon,
        lastSlug = lastSlug,
        arm_down = arm_down,
        arm_up = arm_up,
        paper_y_origin = paper_y_origin,
        newBookBool = newBookBool,
        firstIntro = firstIntro,
        chapter = chapter,
        counter = counter,
        intro = intro,
        bookmark1 = bookmark1,
        bookmark2 = bookmark2,
        resume_bool = resume_bool,
        bookmark_x = bookmark_x,
        chAdd = chAdd,
        explainerButton = explainerButton,
        inactive = inactive,
        mExplain = mExplain,

        newBookReset = function(self)
            self.newBookBool = true
            self.text_y = self.text_y_origin
            self.lineCount = 1
            self.pageCount = 1
            self.lineLength = 0
            self.newPage = false
            self.newChapter = false
            self.chAdd.y = 0
            self.text = {
                x = 95,
                y = 335,
                y_origin = 335,
                y_saved = 335,
                y_overrun = 100,
                load_y_target_2 = 235,
                load_y_target_1 = 335,
                topMargin = 100,
                opacity = 0,
                y_load = 500
            }

            self.paper = {
                x = -5,
                y = 0,
                w = 810,
                h = 420 + 10*self.line_height,
                h_end = 280,
                y_saved = 400,
                y_origin = 200,
                y_insert_origin = 400,
                load_y_target_2 = 135,
                load_y_target_1 = 235,
                y_load = 400,
                opacity = 1
            }

            self.paper.y_saved = self.paper.y
            self.paper.load_y_target_2 = self.text.load_y_target_2 + 100
            self.paper.load_y_target_1 = self.text.load_y_target_1 + 100
            self.intro.y = self.intro.y_origin
            self.intro.y_plus = 70
            self.intro.opacity_target = 0.7
            self.intro.first = false
            self.intro.set = {{text = 'I can do this.',opacity = 0}}
            self.intro.bool = true
            self.fheader_opacity = 0
            self.lineReady = false
            self.lineCursor = 0
            self.needNextChapter = false
            self.bell = false
            self.lastLine = false
            self.chapter = 0
        end,

        newChapterReset = function(self)
            self.intro.y = self.intro.y_origin
            self.intro.y_plus = 70
            self.intro.opacity_target = 0.7
            self.intro.first = false
            self.chAdd.y = 0
            self.intro.set = {}
            self.intro.bool = true
            self.lineReady = false
            self.text.y = self.text.y_origin
        end,

        newPageReset = function(self)

        end,

        bookReady = function(self,start)
            self.needNextChapter = true
            if self.intro.first then
                self:getNextChapter(self.chapter+1)
                --self:miniExplainer(3)
            end
            if start and start == 'start' then
                self:getNextChapter(self.chapter+1)
                self:introPrep()
            end
        end,

        introPrep = function(self,delay)
            local delay = delay or 0.01
            self.pageCount = 1
            local period = math.ceil(self.x_plus/100)/10
            if period < 0 then
                period = -1*period
            end
            typeTimer.after(delay,function()
                sounds.carriage_return_short:play()
                typeTimer.tween(0.3,self,{x_plus=0})
                typeTimer.after(1, function()
                    self:runIntro('new')
                end)
            
            end)
        end,

        runIntro = function(self,new)
            self.newBookBool = false
            self.mask_opacity = 1
            self.mask.x = self.mask.x_intro
            self.mask.opacity = 1
            self.tab = 0
            local delay = 0 or 0.01
            if self.intro.first then
                self:miniExplainer(3)
            end
            if new then
                self.header_opacity = 1
                if self.intro.set and self.intro.set[1] then
                    self.intro.set[1].opacity = self.intro.opacity_target
                end
                if self.intro.set and self.intro.set[2] then
                    self.intro.set[2].opacity = self.intro.opacity_target
                end
                delay = self:introType() or 0.01
                if self.intro.set and self.intro.set[1] then 
                    typeTimer.after(delay, function() typeTimer.tween(2,self.intro.set[1],{opacity=0},'out-cubic')end)
                end
                if self.intro.set and self.intro.set[2] then 
                    typeTimer.after(delay, function() typeTimer.tween(2,self.intro.set[2],{opacity=0},'out-cubic')end)
                end
                typeTimer.after(delay+1, function()
                    self.handle = self.handle_push
                    self.mask.x = self.mask.x_type
                    sounds.carriage_return_short:play()
                    typeTimer.tween(0.3,self,{x_plus=self.x_plus_start})
                    typeTimer.after(0.6,function()
                        self.handle=self.handle_rest
                    end)
                    self:emptySlugs()
                    typeTimer.after(0.6, function()
                        self.text.opacity = 1
                        self.intro.first = false
                        self.lineReady = true 
                        self.typeReady = true
                        self.bell = false
                        self.tab = 40
                        self.intro.bool = false
                        self.newChapter = false
                        self.resume_bool = false
                    end)
                end)
            end
        end,

        newPageStart = function(self)
            self.handle = self.handle_push
            self.mask.x = self.mask.x_type
            if self.x_plus > -100 then
                sounds.carriage_return_short:play()
            else
                sounds.carriage_return_long:play()
            end
            local period = math.max(math.ceil((self.x_plus_start - self.x_plus)/100)/10,0.01)       -- guard against NaN and inf
            typeTimer.tween(period,self,{x_plus=self.x_plus_start})
            typeTimer.after(period+0.3,function()
                self.handle=self.handle_rest
            end)
            self:emptySlugs()
            typeTimer.after(period+0.3, function()
                self.resume_bool = false
                self.mask.opacity = 1
                self.text.opacity = 1
                self.text.y = self.text.y_origin
                self.intro.first = false
                self.lineReady = true 
                self.typeReady = true
                self.bell = false
                self.tab = 40
                self.intro.bool = false
                if self.needNextChapter then
                    self:getNextChapter(3)
                end
            end)
        end,

        introType = function(self)
            local speed = 75
            local cycle = 12
            local delay = 0
            local delay1 = 0
            local delay2 = 0
            local introSlugs = {}
            local innerIntroSlugs = {}
            local delays = {}
            local delayCount = 0
            local delayCounter = 0
            local bigDelay = 0
            local scrollDelay = 0
            local handle1
            local handle2
            local num = #self.intro.set + 1
            for i = 1, num do
                for j = 1, cycle do 
                    delayCount = love.math.random(2, 6)/speed       -- Guard against NaN
                    table.insert(innerIntroSlugs, delayCount)
                    delayCounter = delayCounter+delayCount
                    delayCount = love.math.random(5, 9)/speed        -- Guard against NaN
                    table.insert(innerIntroSlugs, delayCount)
                    delayCounter= delayCounter+delayCount
                end
                table.insert(introSlugs, innerIntroSlugs)
                innerIntroSlugs = {}
                table.insert(delays, delayCounter)
                delayCounter = 0
            end
            for i = 1, num do
                typeTimer.after(bigDelay,function()
                    for j = 1, cycle do
                        delay1 = table.remove(introSlugs[i], 1)
                        delay2 = table.remove(introSlugs[i], 1)
                        typeTimer.after(delay, function()
                            self:introSlug(delay1,delay2)
                        end)
                        delay = delay+delay1+delay2
                    end
                    bigDelay = bigDelay + delays[i]
                end)
                scrollDelay = scrollDelay + delays[i]
                typeTimer.after(scrollDelay+0.3+(i-1), function()
                    sounds.roller_double:play()
                    if i == 2 then
                        typeTimer.cancel(handle1)
                        typeTimer.tween(0.3,self.intro.set[1],{opacity=0},'out-cubic')
                    elseif i == 3 then
                        typeTimer.cancel(handle2)
                        typeTimer.tween(0.3,self.intro.set[2],{opacity=0},'out-cubic')
                    end
                    typeTimer.tween(0.2,self.intro,{y=self.intro.y-self.intro.y_plus},'in-out-quad',function()
                        typeTimer.after(0.1,function()
                            typeTimer.tween(0.2,self.intro,{y=self.intro.y-self.intro.y_plus},'in-out-quad', function()
                                if i == 1 and self.intro.set and self.intro.set[1] then
                                    handle1 = typeTimer.tween(4,self.intro.set[1],{opacity=0})
                                elseif i == 2 and self.intro.set and self.intro.set[2] then
                                    handle2 = typeTimer.tween(4,self.intro.set[2],{opacity=0})
                                end
                            end)
                        end)
                    end)
                end)
                bigDelay = bigDelay+0.8
            end
            local totalDelay = 0
            for _,v in ipairs(delays) do
                totalDelay = totalDelay + v
            end
            totalDelay = totalDelay + 0.9*#delays
            return totalDelay                       
        end,

        introSlug = function(self,delay1,delay2)
            self.slug = rng:random(1,5)
            local sound = rng:random(1,5)
            typeSound(sound)
            typeTimer.after(delay1, function()
                self.lastSlug = self.slug
                self.slug = 6
                self.tape.y = self.tape.y_type
                typeTimer.after(delay2, function() 
                    self.lastSlug = 7
                    self.slug = 7
                    self.tape.y = self.tape.y_rest
                end)
            end)
        end,

        getNextChapter = function(self, num)
            if self.needNextChapter and num > self.chapter then
                self.pages = {}
                self.pages = BOOK:next()
                self.chapter = BOOK.currentTwChapter
                if self.pages and type(self.pages) == "string" then
                elseif self.pages then
                    self.needNextChapter = false
                    --self.chapter = self.chapter + 1
                    self.pageCount = 1
                    self.lineCount = 1
                    if #self.pages[self.pageCount][self.lineCount]*self.charPx then
                        self.lineLength = #self.pages[self.pageCount][self.lineCount]*self.charPx
                    else
                        getBook()
                    end
                    self.x_plus_min = self.x_plus_start-self.lineLength
                    if self.chapter > 1 or self.resume_bool then
                        self:newChapterReset()
                    end
                else
                    print('BOOK:next() failed')
                end
            end
        end,

        miniExplainer = function(self,delay)
            local delay = delay or 0.01
            self.mExplain = miniExplain()
            self.mExplain:open(delay)
        end,

        loadNewChapter = function(self)

        end,

        getTextSeen = function(self)
            local next = false 
            local concatLines = {}
            for i = #self.pages[self.pageCount], 1, -1 do
                if next then
                    table.insert(concatLines, 1, self.pages[self.pageCount][i]..'\n\n')      
                else                                                                           
                    table.insert(concatLines, 1, self.pages[self.pageCount][i])
                end
                if string.sub(self.pages[self.pageCount][i], 1,2) == '  ' then
                    next = true
                else
                    next = false
                end
            end
            local tempText = table.concat(concatLines, '', 1, self.lineCount-1)
            local rumpPx = self.x_plus_start - self.x_plus/self.charPx   
            local rumpChar = math.floor(rumpPx/self.charPx)
            local rumpTxt = string.sub(self.pages[self.pageCount][self.lineCount], 1,rumpChar)
            local partialConcatText = tempText..rumpTxt
            self.concatText = table.concat(concatLines, '')
            return partialConcatText 
        end,

        loadNewPage = function(self,delay1)
            typeTimer.after(0.5,function()
                typeTimer.tween(delay1,self.paper_insert,{h=self.paper_insert.h_target})
            end)
            typeTimer.after(0.5+delay1+0.3,function()
                love.audio.stop(sounds.roller1)
                sounds.roller1:play()
                typeTimer.tween(0.5,self.paper,{y=self.paper.load_y_target_1},'out-cubic')
            end)
            typeTimer.after(1.3+delay1,function()
                self.mask.y = self.mask.y_origin
                self.gate.sy = 1
                self.gate.y_pos = self.gate.y_down
                sounds.gateSnapDown:play()
                self:newPageStart()
            end)
        end,

        getLoadScrolls = function(self)
            local scrolls = {}
            scrolls.total = math.ceil((self.lineCount-1)/4)
            self.paper.y = self.paper.y_load 
            self.mask.y = self.mask.y_load + (self.lineCount-1)*self.line_height
            self.text.y = self.text.y_load
            scrolls.first = 100
            scrolls.second = (self.line_height)*6
            scrolls.rest = (self.line_height)*4
            return scrolls
        end,

        loadOldPage = function(self,delay1)
            self.paper.h = 200 + 13*self.line_height 
            self.mask.opacity = 1
            self.text.opacity = 1
            if self.resume_bool then
                self.mask.x = self.mask.x_type + self.x_plus_start - self.bookmark_x
            end
            local scrolls = self:getLoadScrolls()
            typeTimer.after(1,function()
                typeTimer.tween(delay1,self.paper_insert,{h=self.paper_insert.h_target})
            end)
            typeTimer.after(delay1 + 1 + 1, function ()
                sounds.roller1:play()
                typeTimer.tween(delay1,self.paper,{y=self.paper.y-scrolls.first},'out-cubic')
                typeTimer.tween(delay1,self.text,{y=self.text.y-scrolls.first},'out-cubic')
                typeTimer.tween(delay1,self.mask,{y=self.mask.y-scrolls.first},'out-cubic')
            end)
            typeTimer.after(delay1*2 + 1 + 1 + 1, function()
                love.audio.stop(sounds.roller1)
                sounds.roller1:play()
                typeTimer.tween(delay1,self.paper,{y=self.paper.y-scrolls.second},'out-cubic')
                typeTimer.tween(delay1,self.text,{y=self.text.y-scrolls.second},'out-cubic')
                typeTimer.tween(delay1,self.mask,{y=self.mask.y-scrolls.second},'out-cubic')
            end)
            if scrolls.total > 1 then
                for i = 1, scrolls.total-1 do
                    typeTimer.after(delay1*3 + 1 + 1 + 1 + 1 + (delay1+1)*(i-1),function()
                        love.audio.stop(sounds.roller1)
                        sounds.roller1:play()
                        typeTimer.tween(delay1,self.paper,{y=self.paper.y-scrolls.rest},'out-cubic')
                        typeTimer.tween(delay1,self.text,{y=self.text.y-scrolls.rest},'out-cubic')
                        typeTimer.tween(delay1,self.mask,{y=self.mask.y-scrolls.rest},'out-cubic')
                    end)
                end
            end
            typeTimer.after(delay1*3 + 1 + 1 + 1 + 1 + (delay1+1)*(scrolls.total-2) + 2,function()
                love.audio.stop(sounds.roller1)
                sounds.roller1:play()
                typeTimer.tween(delay1+2,self.paper,{y=self.paper.y-(self.mask.y - self.mask.y_origin)},'out-quint')
                typeTimer.tween(delay1+2,self.text,{y=self.text.y-(self.mask.y - self.mask.y_origin)},'out-quint')
                typeTimer.tween(delay1+2,self.mask,{y=self.mask.y_origin},'out-quint')
            end)
            typeTimer.after(delay1*3 + 1 + 1 + 1 + 1 + (delay1+1)*(scrolls.total-2) + 2 + delay1 + 1 + 1,function()
                self.gate.sy = 1
                self.gate.y_pos = self.gate.y_down
                sounds.gateSnapDown:play()
                self:emptySlugs()
                local resume_delay = 0.01
                if self.resume_bool then
                    self.handle = self.handle_push
                    if self.bookmark_x < 0 then
                        sounds.carriage_return_long:play()
                    else
                        sounds.carriage_return_short:play()
                    end
                    local period = math.max(math.ceil((self.x_plus - self.bookmark_x)/75)/10,0.01)
                    typeTimer.tween(period,self,{x_plus=self.bookmark_x})
                    typeTimer.tween(period,self.mask,{x=self.mask.x_type})
                    typeTimer.after(period+0.3,function()
                        self.handle=self.handle_rest
                    end)
                    resume_delay = period + 0.4
                end
                typeTimer.after(resume_delay, function()
                    self.mask.opacity = 1
                    self.text.opacity = 1
                    self.mask.x = 385
                    self.intro.first = false
                    self.lineReady = true 
                    self.typeReady = true
                    self.bell = false
                    self.tab = 40
                    self.intro.bool = false
                end)
            end)
        end,

        resume = function(self)
            print("tw resume arrived 1")
            self.pages = {}
            local bookmark = {}
            self.pages,bookmark = BOOK:resume('tw')
            if not bookmark.chapter or bookmark.chapter < BOOK.currentRChapter then
                print("tw resume arrived 2")
                self:newBookReset()
                self:bookReady('start')
            else
                print("tw resume arrived 3")
                if bookmark.chapter then
                    print("tw resume arrived 4")
                    self.chapter = bookmark.chapter
                    self.pageCount = bookmark.pageCount
                    self.lineCount = bookmark.lineCount
                    self.bookmark_x = bookmark.x_pos
                    if bookmark.introBool then
                        print("tw resume arrived 5")
                        self.resume_bool = true
                        self:newChapterReset()
                        self:introPrep()
                    else
                        print("tw resume arrived 6")
                        self.resume_bool = true
                        self.x_plus = self.x_plus_start
                        self:paperLoad()
                    end
                else
                    print("tw resume arrived 7")
                    self.resume_bool = true
                    self.needNextChapter = true
                    self:getNextChapter(1)
                end
            end
        end,

        bookmarkIt = function(self,twRemain)
            local rumpText = self:getTextSeen()
            BOOK:bookmarkIt('tw',self.chapter,self.pageCount,self.lineCount,self.x_plus,self.newPage,self.newChapter,self.intro.bool,rumpText)
            if twRemain == nil then
                typeTimer.clear()
            end
        end,

        clearTimer = function(self)
            self.randomSlug = {} 
            self.slug = 7
            self.lastSlug = 7
            self.tape.y = self.tape.y_rest
            for _,v in ipairs(self.intro.set) do 
                v.opacity = 0
            end
            self.header_opacity = 0
            typeTimer.clear()
        end,

        paperLoad = function(self)
            self:paperOn()
            self.mask.opacity = 0
            self.typeReady = false
            DEALER = {}
            TRASHER = {}
            if self.newChapter then
                self:getNextChapter(self.chapter+1)
                self.text.opacity = 0
                self.lineCount = 1
                self.text.y_saved = self.text.y_origin
                self.paper.y_saved = 0
                self.paper.y = 400
                if self.newBookBool then 
                    self.paper.h = 900
                else
                    self.paper.h = 420 + 7*self.line_height
                end
            elseif self.newPage then
                self.text.opacity = 0
                self.pageCount = self.pageCount + 1
                self.lineCount = 1
                self.lineLength = #self.pages[self.pageCount][self.lineCount]*self.charPx
                self.x_plus_min = self.x_plus_start-self.lineLength
                self.text.y_saved = self.text.y_origin
                self.paper.y_saved = self.paper.y_origin 
                self.paper.y = 400
                self.paper.h = 200 + 13*self.line_height 
            end
            self.text.load_y_target_1 = self.text.y_saved 
            self.paper.load_y_target_1 = self.paper.y_saved
            local step_y = (self.paper.y-self.paper.load_y_target_1)/2
            self.text.load_y_target_2 = self.text.load_y_target_1 - self.text.y_overrun 
            self.paper.load_y_target_2 = self.paper.load_y_target_1 - self.text.y_overrun 
            self.paper_insert.y = -90
            self.paper_insert.h = 90
            local delay1 = 0.3
            self.gate.sy = -1
            self.gate.y_pos = self.gate.y_up
            sounds.gateSnapUp:play()
            if self.newChapter then
                typeTimer.after(1,function()
                    typeTimer.tween(delay1,self.paper_insert,{h=self.paper_insert.h_target})
                end)
                typeTimer.after(1+0.5+delay1, function()
                    sounds.roller1:play()
                    typeTimer.tween(0.5,self.paper,{y=self.paper.load_y_target_1+step_y},'out-cubic')
                end)
                typeTimer.after(1+1+delay1+0.5,function()
                    love.audio.stop(sounds.roller1)
                    sounds.roller1:play()
                    typeTimer.tween(0.5,self.paper,{y=self.paper.load_y_target_1},'out-cubic')
                end)
                typeTimer.after(3.5+delay1,function()
                    self.gate.sy = 1
                    self.gate.y_pos = self.gate.y_down
                    sounds.gateSnapDown:play()
                    self:introPrep(1)
                end)
            elseif self.newPage then
                self:loadNewPage(delay1)
            else
                self:loadOldPage(delay1)
            end
        end,

        removeFast = function(self)
            self.randomSlug = {}
            self.randomSound = {}
            local hitch = 50
            local span = self.paper.y + self.paper.h + 100
            local period = 0.5
            sounds.roller1:play()
            typeTimer.tween(period,self.text,{y=self.text.y-hitch})
            typeTimer.tween(period,self.paper,{y=self.paper.y-hitch})
            typeTimer.tween(period,self.paper_insert,{y=self.paper_insert.y+hitch})
            typeTimer.tween(period,self.mask,{y=self.mask.y-hitch})
            typeTimer.tween(period,self.intro,{y=self.intro.y-hitch})
            typeTimer.after(0.5,function()
                sounds.paper_removed:play()
                typeTimer.tween(period,self.text,{y=self.text.y-span})
                typeTimer.tween(period,self.paper,{y=self.paper.y-span})
                typeTimer.tween(period,self.paper_insert,{y=self.paper_insert.y+span})
                typeTimer.tween(period,self.mask,{y=self.mask.y-span})
                typeTimer.tween(period,self.intro,{y=self.intro.y-span})
                typeTimer.after(period,function()
                    sounds.paper:play()
                end)   
            end)
            return period*3
        end,

        paperRemove = function(self,txt,bookmark,maskUp,reopen)
            sounds.roller1:play()
            self.typeReady = false
            self.lineReady = false
            if self.lineCount == #self.pages[self.pageCount] and self.x_plus <= self.x_plus_min then
                self.newPage = true
                if self.pageCount == #self.pages then
                    self.newChapter = true
                    self.needNextChapter = true
                else
                    self.newChapter = false 
                end
                self.bookmark1 = 0
                self.bookmark2 = 0
            elseif maskUp ~= 2 then
                self.text.y_saved = self.text.y
                self.paper.y_saved = self.paper.y
                self.newChapter = false 
                self.newPage = false
            end
            typeTimer.after(1, function()
                typeTimer.tween(0.5,self.text,{y=self.text.y-120})
                typeTimer.tween(0.5,self.chAdd,{y=self.chAdd.y-120})
                typeTimer.tween(0.5,self.paper,{y=self.paper.y-120})
                typeTimer.tween(0.5,self.paper_insert,{y=self.paper_insert.y+120})
                if maskUp and maskUp == 1 then
                    typeTimer.tween(0.5,self.mask,{y=self.mask.y-120})
                else
                    self.mask.opacity = 0
                end
                local yTarg = 700
                local periodTarg = 0.5
                local delayTarg = 3
                if self.paper.y > -300 then
                    yTarg = 1400
                    periodTarg = 1
                    delayTarg = 2.5
                end
                typeTimer.after(delayTarg,function()
                    sounds.paper_removed:play()
                    typeTimer.tween(periodTarg,self.text,{y=self.text.y-yTarg})
                    typeTimer.tween(periodTarg,self.chAdd,{y=self.chAdd.y-yTarg})
                    typeTimer.tween(periodTarg,self.paper,{y=self.paper.y-yTarg})
                    typeTimer.tween(periodTarg,self.paper_insert,{y=self.paper_insert.y+yTarg})
                    if maskUp and maskUp == 1 or maskUp == 2 then
                        typeTimer.tween(periodTarg,self.mask,{y=self.mask.y-yTarg})
                    end
                    sounds.paper:play()
                    self.header_opacity = 0
                    local chStart = 'no'
                    if reopen and reopen == 'reopen' then
                        typeTimer.after(3,function()
                            self:resume()
                        end)
                        return
                    end
                    if self.pageCount == 1 then
                        chStart = string.format('CHAPTER %s',string.upper(self.header[self.chapter]))
                    end
                    typeTimer.after(1,function()
                        self.mask.opacity = 0
                        self.mask.y = self.mask.y_origin
                        self.bookmark1 = self.bookmark2 or 0
                        self.bookmark2 = bookmark
                        Timer.cancel(TYPEWRITER.explainerButton.handle)
                        EXPLAINER = {}
                        self.mExplain = {}
                        if GAME_LOOP == 1 then
                            DEALER = evalPageFormat(txt,chStart,bookmark)
                        elseif GAME_LOOP == 2 then
                            DEALER = evalPageFormat(txt,chStart,bookmark)
                        else
                            DEALER = evalPageFormat(txt,chStart,bookmark)
                        end

                        GAME_STATE = 2
                    end)
                end)
            end)
        end,

        typeLoad = function(self)
            if self.typeReady and self.lineReady then
                for i = 1, 3 do
                    table.insert(self.randomSlug, rng:random(1,5))
                    table.insert(self.randomSound, rng:random(1,5))
                end
            end
        end,

        paperOff = function(self)
            self.paper.opacity = 0
            self.mask.opacity = 0
        end,

        paperOn = function(self)
            self.paper.opacity = 1
            self.mask.opacity = 1
        end,

        bypass = function(self)
            local next = false 
            local concatLines = {}
            for i = #self.pages[self.pageCount], 1, -1 do
                if next then
                    table.insert(concatLines, 1, self.pages[self.pageCount][i]..'\n\n')
                else
                    table.insert(concatLines, 1, self.pages[self.pageCount][i])
                end
                if string.sub(self.pages[self.pageCount][i], 1,2) == '  ' then
                    next = true
                else
                    next = false
                end
            end
            self.concatText = table.concat(concatLines, '')
            self.newPage = true
            if self.pageCount == #self.pages then
                self.newChapter = true
                self.needNextChapter = true
            else
                self.newChapter = false 
            end
            self.header_opacity = 0
            self.mask.opacity = 0
            local chStart = 'no'
            if self.pageCount == 1 then
                chStart = string.format('CHAPTER %s',string.upper(self.header[BOOK.currentTwChapter]))
            end
            Timer.cancel(TYPEWRITER.explainerButton.handle)
            EXPLAINER = {}
            self.mExplain = {}
            DEALER = evalPageFormat(self.concatText,chStart)

            GAME_STATE = 2
        end,



        onPress = function(self,key)
            local delay
            if self.inactive then
                return
            end
            if key == 'i' then
                delay = self.explainerButton:explainerOpen()
                return
            end
            if key == '2' then
                self:bypass()
                return
            end
            if key == '1' then
                self:interrupt()
            end
            if key == 'escape' then
                return
            end
            if #self.randomSlug <= 1 then
                self.addSlugReady = true
                self.typeReady = true
            end
            if self.addSlugReady then
                self:typeLoad()
                if #self.randomSlug >= 6 then
                    self.addSlugReady = false
                end
            end
            if self.lineReady then
                if self.x_plus <= self.x_plus_min then
                    self:startCarriageReturn()
                end
            end
        end,

        type = function(self)
            if self.lineReady and self.typeReady then
                if not self.intro.bool and self.x_plus <= self.x_plus_min then
                    self.x_plus = self.x_plus_min
                    if not self.lastLine then
                        if self.bell == true then
                            sounds.carriage_return_long:play()
                        else
                            sounds.carriage_return_short:play()
                        end
                    end
                    self:startCarriageReturn()
                else
                    self.typeReady = false
                    self.slug = table.remove(self.randomSlug, 1)
                    local sound = table.remove(self.randomSound, 1)
                    typeSound(sound)
                    self.typeReady = false
                    self.x_plus = self.x_plus - self.tab
                    if self.x_plus <= -150 and not self.bell then
                        sounds.bell:play()
                        self.bell = true
                    end
                    typeTimer.after((love.math.random(2, 6)/self.type_speed), function()         -- Guard against NaN
                        self.lastSlug = self.slug
                        self.slug = 6
                        self.tape.y = self.tape.y_type
                        typeTimer.after((love.math.random(5, 9)/self.type_speed), function()         -- Guard against NaN
                            self.lastSlug = 7
                            self.slug = 7
                            self.tape.y = self.tape.y_rest
                        end)
                    end)
                    typeTimer.after(0.2,function()
                        self.typeReady = true
                        if not self.intro.bool and self.x_plus <= self.x_plus_min then
                            self.x_plus = self.x_plus_min
                            if not self.lastLine then
                                if self.bell == true then
                                    love.audio.stop(sounds.carriage_return_long)
                                    love.audio.stop(sounds.carriage_return_long)
                                    sounds.carriage_return_long:play()
                                else                                    
                                    love.audio.stop(sounds.carriage_return_long)
                                    love.audio.stop(sounds.carriage_return_long)
                                    sounds.carriage_return_short:play()
                                end
                                self:startCarriageReturn()
                            end
                        end
                    end)
                end
            end
        end,

        interrupt = function(self,reopen)
            local partialConcatText = self:getTextSeen()
            self.newPage = false
            local maskUp = 1
            self:paperRemove(self.concatText,#partialConcatText,maskUp,reopen)    -- Page index of last char
        end,

        startCarriageReturn = function(self)
            if self.typeReady and self.lineReady then
                if self.lineCount == #self.pages[self.pageCount] then
                    local next = false 
                    local concatLines = {}
                    for i = #self.pages[self.pageCount], 1, -1 do
                        if next then
                            table.insert(concatLines, 1, self.pages[self.pageCount][i]..'\n\n')
                        else
                            table.insert(concatLines, 1, self.pages[self.pageCount][i])
                        end
                        if string.sub(self.pages[self.pageCount][i], 1,2) == '  ' then
                            next = true
                        else
                            next = false
                        end
                    end
                    self.concatText = table.concat(concatLines, '')
                    self:paperRemove(self.concatText)  -- pass complete text as argument
                    return                
                end
                self.typeReady = false
                self.lineReady = false
                self.carriageReturn = true
                local temp = self.text.y 
                local temp2 = self.chAdd.y
                self.handle = self.handle_push
                local period = math.max(math.ceil(((self.x_plus_start-self.x_plus)*100)/1500)/100,0.15)
                typeTimer.tween(0.2,self.text,{y=temp-self.line_height})
                typeTimer.tween(0.2,self.chAdd,{y=temp2-self.line_height})
                typeTimer.tween(0.2,self.paper,{y=self.paper.y-self.line_height})
                typeTimer.tween(0.2,self.paper_insert,{y=self.paper_insert.y+self.line_height})
                typeTimer.after(0.1, function()
                    typeTimer.tween(period,self,{x_plus=self.x_plus_start})
                    typeTimer.after(period + 0.01, function()
                        self.carriageReturn = false 
                        self:emptySlugs()
                        self.lineReady = true 
                        self.typeReady = true
                        self.bell = false
                        self.lineCount = self.lineCount + 1
                        if self.lineCount == #self.pages[self.pageCount] then
                            self.lastLine = true
                        end
                        self.lineLength = #self.pages[self.pageCount][self.lineCount]*self.charPx 
                        self.x_plus_min = self.x_plus_start - self.lineLength
                        typeTimer.after(0.2, function()
                            self.handle = self.handle_rest
                        end)
                        self.mask.opacity = 1
                    end)
                end)
            end
        end,

        emptySlugs = function(self)
            self.randomSlug = {}
            self.randomSound = {}
        end,

        draw = function(self)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(room.room,-150,-50,nil,0.6)
            love.graphics.setColor(1,1,1,0.1)
            love.graphics.draw(ICONS.twShadow,35,25,nil,0.25)
            love.graphics.setColor(1,1,1,0.1)
            love.graphics.draw(ICONS.mugShadow,600,25,nil,0.3)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(room.trash_back,440,110,nil,0.18)
            if PAPERS and PAPERS[1] then
                for i,v in ipairs(PAPERS) do
                    if v.flying == false then
                        v.ani:draw(v.img,300+v.x,150+v.y,v.ro,v.scale)
                    end
                end
            end
            love.graphics.draw(room.trash_front,440,115,nil,0.18)
            love.graphics.setColor(1,1,1,self.paper.opacity)
            love.graphics.rectangle('fill',self.paper.x+self.x_plus,self.paper_insert.y,self.paper.w,self.paper_insert.h)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(tw.roll, self.roll.x+self.x_plus,self.roll.y,nil,self.roll.scale)
            love.graphics.setColor(1,1,1,self.paper.opacity)
            love.graphics.rectangle('fill',self.paper.x+self.x_plus,self.paper.y,self.paper.w,self.paper.h)
            love.graphics.setLineWidth(2)
            love.graphics.setColor(0.9,0.9,0.9,self.paper.opacity)
            love.graphics.rectangle('line',self.paper.x+self.x_plus,self.paper.y,self.paper.w,self.paper.h)
            love.graphics.setFont(FONT.robotoL)
            love.graphics.setColor(1,0,0)
            for i,v in ipairs(self.intro.set) do
                love.graphics.setColor(0,0,0,v.opacity)
                love.graphics.print(v.text, 550,self.intro.y+(i-1)*self.intro.y_plus*2)
            end
            if self.pageCount == 1 then
                local chAdj = BOOK.currentTwChapter
                if BOOK.currentTwChapter == 0 then
                    chAdj = 1
                end
                local multiple = #self.intro.set*2
                love.graphics.setColor(0,0,0,self.header_opacity)
                love.graphics.setFont(FONT.courier)
                love.graphics.printf(string.format('CHAPTER %s',string.upper(self.header[chAdj])),self.x_plus,self.intro.y+multiple*self.intro.y_plus+self.chAdd.y,800,'center')
            end
            self.counter = self.counter + 1
            love.graphics.setColor(0,0,0,self.text.opacity)
            love.graphics.setFont(FONT.courier)
            if self.pages and self.pages[1] then
                for i,v in ipairs(self.pages[self.pageCount]) do
                    if i <= self.lineCount and self.text and self.text.y then
                        love.graphics.print(v,self.text.x+self.x_plus,self.text.y+self.line_height*(i-1))
                    end
                end
            end
            love.graphics.setColor(1,1,1,self.mask.opacity)
            love.graphics.rectangle('fill',self.mask.x,self.mask.y,self.mask.w+self.x_plus,self.mask.h)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(tw.gate,self.gate.x+self.x_plus,self.gate.y+self.gate.y_pos,0,1,self.gate.sy)
            love.graphics.draw(self.handle,self.handle_x+self.x_plus,self.handle_y)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(room.carpet_slice, 0, 370)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle('fill',self.tape.x,self.tape.y,self.tape.w,self.tape.h)
            love.graphics.setColor(1,1,1,self.slug_opacity[self.slug])
            love.graphics.draw(self.slugs[self.slug],self.slug_x[self.slug],self.slug_y[self.slug],0,self.slug_scale[self.slug])
            love.graphics.setColor(1,1,1)
            love.graphics.draw(tw.body,self.body.x,self.body.y)
            love.graphics.setColor(0.7,0.7,0.7,0.5)
            love.graphics.setLineWidth(5)
            love.graphics.line(self.arm_down[self.lastSlug])
            love.graphics.setColor(0.7,0.7,0.7,0.3)
            love.graphics.line(self.arm_up[self.slug])
            love.graphics.setLineWidth(1)
            self.explainerButton:draw()
            if self.mExplain and self.mExplain.screen then
                self.mExplain:draw()
            end
            love.graphics.setColor(1,1,1)
            if PAPERS and PAPERS[1] then
                for i,v in ipairs(PAPERS) do
                    if v.flying then
                        v.ani:draw(v.img,300+v.x,150+v.y,v.ro,v.scale)
                    end
                end
            end
        end
    }
end

local sources = {}

function typeSound (randomSound)
    if sources and sources[1] then
        love.audio.stop(table.remove(sources,1))
    end
    if randomSound == 1 then
        sounds.key_space:play()
        table.insert(sources, sounds.key_space)
    elseif randomSound == 2 then
        sounds.key_space2:play()
        table.insert(sources, sounds.key_space2)
    elseif randomSound == 3 then
        sounds.key1:play()
        table.insert(sources, sounds.key1)
    elseif randomSound == 4 then
        sounds.key2:play()
        table.insert(sources, sounds.key2)
    elseif randomSound == 5 then
        sounds.key3:play()
        table.insert(sources, sounds.key3)
    elseif randomSound == 6 then
        sounds.key4:play()
        table.insert(sources, sounds.key4)
    elseif randomSound == 7 then
        sounds.key5:play()
        table.insert(sources, sounds.key5)
    end
end

