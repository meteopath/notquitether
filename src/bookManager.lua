END_BOOL = false

function book(txt, gut_id, bIdx, pref, chapterIndex, chapterOne)
    local title = SearchIndex[pref][bIdx].title
    local author = SearchIndex[pref][bIdx].author
    local dls = SearchIndex[pref][bIdx].dls
    local date = SearchIndex[pref][bIdx].date
    local subject = SearchIndex[pref][bIdx].subject
    local link = SearchIndex[pref][bIdx].link
    local bMark = {}
    local twChapters = {}
    local readChapters = {}
    local currentTwChapter = 0
    local currentRChapter = 0
    local new = true
    local fullText = txt
    local twPagesF = {}
    local partialPage = false
    local bookmark_tw = {}
    local bookmark_read = {}
    local first500 = ''
    local textSeen = {}
    local textSeenChapter = 0

    return {
        gut_id = gut_id,
        chapterIndex = chapterIndex,
        chapterOne = chapterOne,
        title = title,
        author = author,
        dls = dls,
        date = date,
        subject = subject,
        link = link,
        bMark = bMark,
        twChapters = twChapters,
        twPagesF = twPagesF,
        readChapters = readChapters,
        currentTwChapter = currentTwChapter,
        currentRChapter = currentRChapter,
        new = new,
        fullText = fullText,
        partialPage = partialPage,
        bookmark_tw = bookmark_tw,
        bookmark_read = bookmark_read,
        first500 = first500,
        textSeen = textSeen,
        textSeenChapter = textSeenChapter,

        next = function(self)
            -- TODO: create 'THE END' screens
            self.new = false
            if TYPEWRITER_MODE then
                if self.currentTwChapter > #self.chapterIndex then
                    END_BOOL = false
                    getBook()
                elseif self.currentTwChapter == #self.chapterIndex then
                    END_BOOL = true
                    return self:getTwEndPage()
                else
                    self.currentTwChapter = self.currentTwChapter + 1
                    if self.currentRChapter > self.currentTwChapter then 
                        self.currentTwChapter = self.currentRChapter 
                    end
                    return self:getNextTwChapter()
                end
            else
                if self.currentRChapter == 0 then
                    self.currentRChapter = self.currentRChapter + 1
                    return self:getNextRChapter()
                elseif self.currentRChapter > #self.chapterIndex then 
                    return
                elseif self.currentRChapter == #self.chapterIndex then 
                    self.currentRChapter = self.currentRChapter + 1
                    END_BOOL = true
                    return self:getReadEndPage()
                elseif self.readChapters and self.currentRChapter == #self.readChapters then
                    if self.readChapters[self.currentRChapter].pages[#self.readChapters[self.currentRChapter].pages].pos == "left" then
                        self.currentRChapter = self.currentRChapter + 1
                        return self:getNextRChapter()
                    end
                else
                    self.currentRChapter = self.currentRChapter + 1
                end
            end
        end,

        getTwEndPage = function(self) 
            local page = '\n\n\n\n\n\n\n\n\n                 THE END '
            local pages = {}
            table.insert(pages,page) 
            table.insert(self.twChapters,pages)
            return self.twChapters[self.currentTwChapter]
        end,

        getReadEndPage = function(self) 
            local pages = formatReadChapter('THE END',self.currentRChapter,1)
            table.insert(self.readChapters,pages)
            return self.readChapters[self.currentRChapter]
        end,

        initialize = function(self)
            if TYPEWRITER_MODE then
                return self:getNextTwChapter()
            else
                return self:getNextRChapter()
            end
        end,

        getNextTwChapter = function(self)
            if self.currentTwChapter > #self.twChapters then
                for i=#self.twChapters+1,self.currentTwChapter do
                    table.insert(self.twChapters, self:formatTwChapter(i))
                end
            end
            return self.twChapters[self.currentTwChapter]
        end,

        getNextRChapter = function(self)
            if self.currentRChapter > #self.readChapters then
                local pageCount = 0
                if #self.readChapters > 0 then
                    pageCount = self.readChapters[#self.readChapters].pages[#self.readChapters[#self.readChapters].pages].index
                end 
                for i=#self.readChapters+1,self.currentRChapter do
                    local pages = self:formatRChapter(i,pageCount)
                    table.insert(self.readChapters, pages)
                end
            end
            return self.readChapters[self.currentRChapter]
        end,

        formatTwChapter = function(self,index)
            local txt = ''
            if self.currentTwChapter == 1 then
                txt = self.chapterOne
            else
                local txt0 = string.sub(self.fullText, self.chapterIndex[index],self.chapterIndex[index+1])
                txt,errorFlag = self:getByteRightChapter(txt0)
            end
            local maxLines = 7
            if self.currentTwChapter == 1 then
                maxLines = 10
                self.first500 = string.sub(txt,1,500)
            end
            return getTwText(txt,maxLines,errorFlag)
        end,

        formatRChapter = function(self,index,pageCount)
            local txt = ''
            if self.currentRChapter == 1 then
                print('chapter1 R arrived')
                txt = self.chapterOne
            else
                local txt0 = string.sub(self.fullText, self.chapterIndex[index],self.chapterIndex[index+1])
                txt,errorFlag = self:getByteRightChapter(txt0)
            end
            return formatReadChapter(txt,index,pageCount,errorFlag)
        end,

        storeIt = function(self,page,bookmark)
            table.insert(self.twPagesF, page)
            if bookmark and bookmark > 0 then
                self.partialPage = true
            else
                self.partialPage = false
            end
        end,

        storeCards = function(self,storedCards)
            if storedCards and storedCards[1] and storedCards[1].text then
                self.twPagesF[#self.twPagesF].storedCards = storedCards 
            end
        end,

        updateIt = function(self)
            return table.remove(self.twPagesF)
        end,

        bookmarkIt = function(self,mode,chapter,pageCount,lineCount,x_pos,newPage,newChapter,introBool,rumpText)
            if mode == 'tw' then
                print('arrived bookmarkIt')
                self.bookmark_tw = {}
                self.bookmark_tw = {
                    chapter = chapter,
                    pageCount = pageCount,
                    lineCount = lineCount,
                    x_pos = x_pos,
                    newChapter = newChapter,
                    newPage = newPage,
                    introBool = introBool,
                    rumpText = rumpText
                }
            elseif mode == 'read' then
                self.bookmark_read = {}
                self.bookmark_read = {
                    pageCount = pageCount,
                    lineCount = lineCount,
                    x_pos = x_pos
                }
            end
        end,

        resume = function(self,mode)
            print('arrived bookManager 1')
            if mode == 'tw' then
                print('arrived bookManager 2')
                for k,v in ipairs(self.bookmark_tw) do 
                    print(k,v) 
                end
                return self.twChapters[self.currentTwChapter],self.bookmark_tw
            elseif mode == 'read' then
                return self.readChapters[self.currentRChapter],self.bookmark_read
            end
        end,

        getByteRightChapter = function(self,txt) 
            print('getByteRight called')
            local byteRightTxt = getByteRight(txt)
            local bytes,chars = checkBytes(byteRightTxt) 
            print('Byte count ************************************* currentRChapter',self.currentRChapter)
            print('bytes: ',bytes,'            chars: ',chars) 
            --print('book index: ',BOOKCOUNT,'book id: ',randId)
            if bytes ~= chars then 
                print('try again')
                local errorText = 'error'                  --getErrorPage(self.currentRChapter)
                local errorFlag = 'error'
                return errorText, errorFlag
            else
                local errorFlag = false
                return byteRightTxt, errorFlag
            end
        end,

--[[         utfError = function(self)
            local txt = getErrorPage(self.currentRChapter)
        end, ]]

        chapterBack = function(self) 
            print("chapterBack 1", self.currentRChapter)
            self.currentRChapter = self.currentRChapter - 1
            print("chapterBack 2", self.currentRChapter)
        end
    }
end

function updateGutChecklist(gutUsed,randNums,pref)
    local checkList = {}
    local gut
    for _,v in ipairs(randNums) do
        gut = SearchIndex[pref][v].gut_id
        table.insert(checkList, gut) 
        if gut == gutUsed then
            for _,w in ipairs(checkList) do
                table.insert(GUTCHECKLIST,tonumber(w)) 
            end
            break
        end
    end
end

function reopenBook(index)
    print('reopenBook index',index)
    closeBook()
    hideSettings()
    BOOK = USERDATA[index]
    print('############## BOOK k,v ')
    for k,v in pairs(BOOK) do 
        print(k)
    end
    print('@@@@@@@@@@@ bookmark_tw from reopenBook()')
    for k,v in ipairs(BOOK.bookmark_tw) do 
        print(k,v)
    end
    getBook(tonumber(BOOK.gut_id))
    DEALER = {}
    READER = {}
    if TYPEWRITER_MODE then
        TYPEWRITER:interrupt('reopen')
    else
        READER = reader()
        for _,v in ipairs(READER.readButtons) do 
            v:open() 
        end
    end
end

local binser = require 'binser.binser'
function closeBook()
    print('closeBook arrived')
    if BOOK.chapterOne then
        if #USERDATA > 0 then
            for _,v in ipairs(USERDATA) do
                if v.gut_id == BOOK.gut_id then
                    goto notNew
                end
            end
        end
        table.insert(USERDATA,BOOK)
        BOOK = {}
        ::notNew::
    end
end

function getTwText(txt,maxLines,errorFlag)
    print('getTwText arrived')
--TT2020E 32 pt is about 44char per 800px or 18.2px/char
    local lines = textWrapTw(txt,14,600,maxLines,errorFlag)
    return lines
end

function textWrapTw(rawText,char_px,line_px,maxL,errorFlag)
    local cursor = 0
    local lineCursor = 0
    local tempTextL = ''
    local tempTextR = ''
    local lines = {}
    local pages = {}
    if errorFlag and errorFlag == 'error' then
        table.insert(lines,"  --> UTF-8 decoding error <--")
        table.insert(lines,"  Could not display CHAPTER "..BOOK.currentTwChapter)
        table.insert(lines,"  Full book available on Project")
        table.insert(lines,"  Gutenberg site: gutenberg.org")
        table.insert(lines,"  For weblink, press [5]")
        table.insert(pages,lines) 
        return pages
    end
    local maxLines = 10                                   -- = maxL or 10
    local rawText1 = ltrim(rawText)
    local text1 = rawText1:gsub(" +", " ")
    local z = prepTop(text1)
    print('z',z)
    local text = ''
    if z > 1 then
        if string.sub(text1,z+1) then
            text = string.sub(text1,z+1)        
        end
    else 
        text = text1
    end
    local txt = text:gsub('\n+', ' $$ ')
    local topT = string.sub(text1,1,z)
    local topT2 = string.gsub(topT, '\n','')
    local maxChar = math.floor(line_px/char_px)
    local textCopy = txt
    local limit = 1
    for i in string.gmatch(textCopy, "%S+") do  
        if i == '$$' then
            tempTextL = string.sub(txt, 1, lineCursor)
            table.insert(lines,tempTextL)
            limit = limit + 1
            if #lines >= maxLines then
                table.insert(pages,lines) 
                lines = {}
                maxLines = 13
            end
            tempTextR = string.sub(txt, lineCursor + 4)
            txt = ''
            txt = '  '..tempTextR
            lineCursor = 2
            cursor = cursor + 2
        elseif lineCursor + #i + 1 > maxChar + 1 then
            local _,z = string.find(string.sub(txt, lineCursor,maxChar), '%-')
            if z then
                tempTextL = string.sub(txt, 1, lineCursor + z - 1)
            else
                tempTextL = string.sub(txt, 1, lineCursor)
            end
            table.insert(lines,tempTextL)
            limit = limit + 1
            if #lines >= maxLines then 
                table.insert(pages,lines) 
                lines = {}
                maxLines = 13
            end
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
    if #lines > 0 then
        table.insert(pages,lines)
    end
    return pages
end

function ltrim(s)
    return s:match'^%s*(.*)'
end

function prepTop(text)
    local noHeader = true 
    local firstChar = string.sub(text,1,1)
    local secondChar = string.sub(text,2,2)
    local thirdChar = string.sub(text,3,3)
    if type(tonumber(firstChar)) == 'number' then
        noHeader = false
    end
    local fA,fZ = string.find(text, '%w+')
    local firstWord = string.sub(text,fA,fZ)
    local lowerBool = string.find(firstWord, '%l')
    if lowerBool == nil then 
        if #firstWord > 1 then
            noHeader = false
        else
            local rNums = {'I','V','X','L'}
            for _,v in ipairs(rNums) do 
                if v == firstWord then 
                    if secondChar == '.' then 
                        noHeader = false 
                    elseif secondChar == '\n' then
                        noHeader = false
                    elseif secondChar == ' ' and thirdChar ~= '%l' then
                        noHeader = false
                    end
                end
            end
        end
    end
    local headerWords = {"chapter","act","part",}
    for _,v in ipairs(headerWords) do
        if string.lower(firstWord) == v then
            noHeader = false
        end
    end
    local z = 1
    if noHeader == false then
        _,z = string.find(text,'\n\n')
    end
    return z
end