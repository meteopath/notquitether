READER = {}
DELAY_HANDLES = {}
PERIOD_HANDLES = {}

local sounds = {
    click = love.audio.newSource("assets/audio/click.wav", "static"),
}
sounds.click:setVolume(0.02)
local sources = {}

function librarian(newQ)
    if DELAY_HANDLES then 
        for _,v in ipairs(DELAY_HANDLES) do
            Timer.cancel(v)
        end
        DELAY_HANDLES = {}
    end 
    local chNum = BOOK.currentRChapter
    local lastPage = #BOOK.readChapters[chNum].pages
    local lastPageBool = false
    local firstPageBool = false
    local infoBool = false
    if BOOK.readChapters then
        if BOOK.readChapters[chNum].pages[lastPage].pos == 'left' then
            lastPageBool = true
        elseif BOOK.readChapters[chNum].pages[1].pos == 'right' then
            firstPageBool = true 
        end
    end
    if newQ == "newBook" then
        bookMark = 0
        getBook()
    elseif newQ == 'info' then
        if infoBool then
            INFO:close()
            infoBool = false
        else
            INFO = infoBoard(150,125,400,400,50)
            INFO:open()
            infoBool = true
        end
    elseif newQ == "nextChapter" then
        if lastPageBool then
            BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
            BOOK:next()
            if END_BOOL then 
                print('end')
            else
                BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
            end
        else
            local c = 0
            for i,v in ipairs(BOOK.readChapters[chNum].pages) do 
                if v.pos == 'right' then
                    local handle = Timer.after(c*0.1, function()
                        BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
                    end)
                    c = c + 1
                    table.insert(DELAY_HANDLES,handle)
                end
            end
            Timer.after((c+1)*0.1, function()
                BOOK:next()
                if END_BOOL then 
                    print('end')
                else
                    BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
                end
            end)
        end
    elseif newQ == "nextPage" then
        if lastPageBool and BOOK.currentRChapter == #BOOK.readChapters then
            BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
            BOOK:next()
        elseif lastPageBool then
            BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
            BOOK:next()
            if END_BOOL then 
                print('end')
            else
                BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
            end
        else
            BOOK.readChapters[BOOK.currentRChapter]:pageTurnForward()
        end
    elseif newQ == "pageBack" then
        if firstPageBool then
            if BOOK.currentRChapter > 1 then
                BOOK:chapterBack()
            end
        else
            BOOK.readChapters[BOOK.currentRChapter]:pageTurnBack()
        end
    elseif newQ == "settings" then
        showSettings()
    elseif newQ == "info" then

    end
end

local readButtons = {
    getButton({'New Book'},librarian,"newBook",0.05*DRAW_WIDTH, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.05+DRAW_HEIGHT_ADJ, (0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9, COLORS.red, {24},{FONT.robotoL},1,{}),
	getButton({'Page Back'},librarian,"pageBack",0.05*DRAW_WIDTH, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*1.05+DRAW_HEIGHT_ADJ, (0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9,COLORS.pink, {24},{FONT.robotoL},4,{}),
	getButton({'Next Page'},librarian,"nextPage",0.1*DRAW_WIDTH+(0.8*DRAW_WIDTH/6)*4, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.05+DRAW_HEIGHT_ADJ, (0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9, COLORS.lightblue, {24},{FONT.robotoL},3,{}),
	getButton({'Next Chapter'},librarian,"nextChapter",0.1*DRAW_WIDTH+(0.8*DRAW_WIDTH/6)*4, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*1.05+DRAW_HEIGHT_ADJ, (0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9, COLORS.blue, {24},{FONT.robotoL},6,{}),
    --getButton({'Next Passage'},librarian,"nextPassage",0.1*DRAW_WIDTH+(0.8*DRAW_WIDTH/6)*4, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*1.05+DRAW_HEIGHT_ADJ, (0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9, COLORS.blue, {24},{FONT.robotoL},6,{}),
	getButton({'Settings/','Details'},librarian,"settings",0.1*DRAW_WIDTH+(0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*1.05+DRAW_HEIGHT_ADJ, ((0.8*DRAW_WIDTH/6)*2.5)/2, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9, COLORS.lightgray, {24,24},{FONT.robotoM,FONT.robotoM},5,{}),
	getButton({'i'},infoHalt, nil, 0.1*DRAW_WIDTH+(0.75*DRAW_WIDTH/6)*2.5, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.05+DRAW_HEIGHT_ADJ, ((0.8*DRAW_WIDTH/6)*2.5)/2, ((DRAW_HEIGHT-DRAW_HEIGHT_ADJ)/2)*0.9, COLORS.lightgray, {24},{FONT.courier},2,{})
}


function drawReader()
    if BOOK and BOOK.readChapters and BOOK.readChapters[1] then
        BOOK.readChapters[BOOK.currentRChapter]:readDraw()
    end
    READER:draw()
end

function reader()
    local readButtons = readButtons
    for _,v in ipairs(readButtons) do 
        v.modals = readButtons 
    end
    BOOK:next()
    return {
        readButtons = readButtons,

        draw = function(self)
            for _,v in ipairs(self.readButtons) do
                v:draw()
            end
        end
    }
end

function formatReadChapter(txt,chNum,pageCount,errorFlag)
    local txt = txt
    local bMarks = {}
    local chNum = chNum
    local pages = getReadPages(txt, chNum,pageCount,errorFlag)
    local endMark = 0
    if pages and pages[1] and pages[1].endMark then
        endMark = pages[1].endMark 
    end
    local read_opacity = {}
    local bMark = 1
    local turnPeriod = 0.5

    return {
        txt = txt,
        twText = twText,
        pages = pages,
        read_opacity = read_opacity,
        bMarks = bMarks,
        chNum = chNum,
        bMark = bMark,
        endMark = endMark,
        turnPeriod = turnPeriod,

        openChapter = function(self)
            if #self.pages[1].bMarks == 0 then
                Timer.after(1, function() Timer.tween(0.2,self.pages[1],{add_x = -400}) end)
                self.pages[1].pos = 'left'
                self.pages[1].seen = true
            end
        end,

        newPassage = function(self)
            for i,page in ipairs(self.pages) do
                if page.pos == 'right' then
                    if #page.bMarks == 0 then
                        self:pageTurnForward()
                        break
                    elseif #page.bMarks == 1 then
                        Timer.tween(1,page.bMarks[1],{opacity = 0},'in-quad', function ()
                            self:pageTurnForward()
                            self.bMark = self.bMark + 1
                        end)
                        break
                    elseif #page.bMarks > 1 then
                        for j,w in ipairs(page.bMarks) do
                            if w.opacity > 0.2 then
                                Timer.tween(1,page.bMarks[j],{opacity = 0},'in-quad')
                                self.bMark = self.bMark + 1
                                if j == #page.bMarks then
                                    Timer.after(1, function() self:pageTurnForward() end)
                                    goto noTurn
                                else
                                    if page.index == page.pageTotal - 1 then
                                        if self.pages.bMarks then
                                            for _,v in ipairs(self.pages.bMarks) do 
                                                Timer.tween(0.2,v,{opacity = 1})
                                            end
                                        end
                                    end
                                    goto noTurn
                                end
                            elseif w.opacity == 0 and j == #page.bMarks then
                                self:pageTurnForward()
                                if page.index == page.pageTotal - 1 then
                                    if self.pages.bMarks then
                                        for _,v in ipairs(self.pages.bMarks) do 
                                            Timer.tween(0.2,v,{opacity = 1})
                                        end
                                    end
                                end
                                goto noTurn
                            end
                        end
                    end
                    ::noTurn::
                    break
                end
            end
        end,

        pageTurnForward = function(self)
            if sources and sources[1] then
                love.audio.stop(table.remove(sources,1))
            end
            sounds.click:play()
            table.insert(sources, sounds.click)
            for i,page in ipairs(self.pages) do
                if page.pos == 'left' then
                    if page.bMarks then
                        for _,v in ipairs(page.bMarks) do
                            v.opacity = 0
                        end
                    end
                end
                if page.pos == 'right' then
                    page.pos = 'left'
                    if page.bMarks then
                        for _,v in ipairs(page.bMarks) do
                            v.opacity = 0
                        end
                    end
                    local handle = Timer.tween(self.turnPeriod,page,{add_x = -400},'in-out-cubic')
                    table.insert(PERIOD_HANDLES,handle)
                    page.seen = true
                    if page.index == page.pageTotal - 1 then
                        if self.pages.bMarks then
                            for _,v in ipairs(self.pages.bMarks) do 
                                Timer.tween(self.turnPeriod,v,{opacity = 1},'in-out-cubic')
                                --table.insert(TIMER_HANDLES,handle2)
                            end
                        end
                    end
                    break
                end
            end
        end,

        pageTurnBack = function(self)
            if sources and sources[1] then
                love.audio.stop(table.remove(sources,1))
            end
            sounds.click:play()
            table.insert(sources, sounds.click)
            for j=#self.pages, 1, -1 do
                if self.pages[j].pos == 'left' then
                    Timer.tween(self.turnPeriod,self.pages[j],{add_x = 0},'in-out-cubic', function() self.pages[j].pos = 'right' end)
                    break
                end
            end
        end,

        twDraw = function(self, add_x,add_y)
            love.graphics.printf(self.twText, FONT.courier, self.tw_x+add_x, self.tw_y+add_y, self.tw_limit)
        end,

        readDraw = function(self)
            love.graphics.setColor(0,0,1)
            for i=#self.pages, 1, -1 do
                if self.pages[i].pos == 'right' then
                    self.pages[i]:draw()
                    --self.pages[i]:drawMask()
                end
            end
            for _,v in ipairs(self.pages) do
                if v.pos == 'left' then
                    v:draw()
                    --v:drawMask()
                end
            end
        end
    }
end

function getReadPages(txt,chNum,pageCount,errorFlag)
    local char = 12
    local pageHeight = 510/600*DRAW_HEIGHT_ADJ
    local specifics = {
        {width = 270, index = 3},
        {width = 350, index = 200}
    }
    local pages,bMarkCount = textWrapSpecifics(txt,char,pageHeight,specifics,chNum,errorFlag)
    local readPages = {}
    local bMarkCounter = 0
    if pages then 
        print('#pages',#pages)
        for i, page in ipairs(pages) do
            local readPage = getReadPage(page,bMarkCounter,bMarkCount, i,chNum,pageCount, #pages)
            table.insert(readPages, readPage)
            bMarkCounter = bMarkCounter + #readPage.bMarks
        end
    end
    return readPages
end

function getReadPage(page,bMarkCounter,bMarkCount, i,chNum,pageCount,pageTotal)
    local index = 0
    if pageCount then
        index = i+pageCount
    else
        index = i 
    end
    local chPageNum = i
    local bMarkCounter = bMarkCounter
    local endMark = bMarkCount or 1
    local text = page.text
    local text_x = 420/800*DRAW_WIDTH
    local text_y = 50/600*DRAW_HEIGHT_ADJ
    local page_x = 410/800*DRAW_WIDTH
    local page_y = 40/600*DRAW_HEIGHT_ADJ
    local page_width = 380/800*DRAW_WIDTH
    local page_height = 550/600*DRAW_HEIGHT_ADJ
    local margin_x = text_x-page_x
    local opacity = 1
    local pos = 'right'
    local add_x = 0
    local bMarks = {}
    if page.bMarks then
        for _,v in ipairs(page.bMarks) do 
            table.insert(bMarks, {x=v.x, y=v.y,opacity=1,num=bMarkCounter,lineHeight=v.lineHeight})
            bMarkCounter = bMarkCounter + 1
        end
    end
    local bMarkIndex = bMarkCounter
    local seen = false
    local chNum = chNum
    if chNum == 0 then
        chNum = 1
    end

    return {
        pageTotal = pageTotal,
        chNum = chNum,
        index = index,
        chPageNum = chPageNum,
        text =text,
        margin_x = margin_x,
        text_x = text_x,
        text_y = text_y,
        page_x = page_x,
        page_y = page_y,
        page_width = page_width,
        page_height = page_height,
        opacity = opacity,
        pos = pos,
        add_x = add_x,
        bMarks = bMarks,
        endMark = endMark,
        bMarkIndex = bMarkIndex,
        seen = seen,

        newPassage = function(self)
        end,

        printSafe = function(self)
            love.graphics.print(self.text, self.text_x+self.add_x, self.text_y)
        end,
        
        draw = function(self)
            love.graphics.setFont(FONT.courierM)
            love.graphics.setColor(0.8,0.8,0.8, self.opacity)
            love.graphics.rectangle('line', self.page_x+self.add_x, self.page_y, self.page_width, self.page_height)
            love.graphics.setColor(1,1,1,self.opacity)
            love.graphics.rectangle('fill', self.page_x+self.add_x, self.page_y, self.page_width, self.page_height)
            love.graphics.setColor(0,0,0,self.opacity)
            love.graphics.print(self.text, self.text_x+self.add_x, self.text_y)
            love.graphics.printf('Ch'..self.chNum..'/'..'p'..self.index, self.text_x+self.add_x,self.page_height,self.page_width,'center')
        end
    }
end





