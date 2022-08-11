local http = require('socket.http')
local mirror = "http://gutenberg.readingroo.ms"

--BOOKCOUNT = 25

FIRST_BOOK = false

local function download(url)
    local ret, status = http.request(url)
    return status == 200 and ret
  end
  
local function get_gutenberg_text(id)
    local sid = tostring(id)
    local s0id = id < 10 and "0" .. sid or sid
    local url = s0id:sub(1, 1)
    for i = 2, #s0id - 1 do
        url = url .. "/" .. s0id:sub(i, i)
    end
    url = mirror .. "/" .. url .. "/" .. sid .. '/' .. sid
    local text = download(url .. "-0.txt") -- utf-8
    --local text = download(url .. ".txt") -- utf-8
    if text then
        return text
    end
    -- We don't know how to convert encodings, so prefer the plain text
    return download(url .. ".txt")
end

local function removeWhitespace(txt)
    local txtA = txt:gsub('\r','')
    local txt0 = txtA:gsub('\n%s+\n','\n\n')
    local txt6 = txt0:gsub(' +\n','\n')
    local txt1 = txt6:gsub("(%S)\n *(%S)", '%1 %2')
    local txt2 = txt1:gsub("(%S\n\n) +", '%1')
    local txt3 = txt2:gsub("(%S\n\n)\n+ +",'%1')
    local txt4 = txt3:gsub("  +"," ")
    local endBook = string.find(txt4,'END OF THE PROJECT GUTENBERG EBOOK')
    local txt5 = ''
    if endBook then 
        txt5 = string.sub(txt4,1,endBook - 5)
    else
        txt5 = txt4        
    end
    return txt5
end

local function findChapterOne(txt,randID)
    local threshold = math.floor(#txt/3)
    local txtLower = string.lower(txt)
    local ch1Test = {
        -- next line was [^%l] instead of [^%w]
        {target = {"chapter 1[%.%s]","chapter i[^%w]","chapter one"}, flag = {"chapter","chapter","chapter"}},
        {target = {"\n\n-1[%.\n]"},flag = {'\n%s*[1-9]'}},
        {target = {'\n\n- *i[%.\n][^%l]'},flag = {"ii"}},
        {target = {"%s%s+O[Nn][Ee]%.","%s%s+one%s%s"},flag = {"two"}},
        {target = {"\n\n-act i[%.%s\n]","\n\n+act 1","\n\n+act one"},flag = {"act ii","act 2","act two"}},
        {target = {"\n\n%s*[%u %p][%u %p][%u %p]+\n\n+%u[ %l][ %l][ %l]"}, flag = {"[%u %p][%u %p][%u %p][%u %p][%u %p][%u %p][%u %p]"}},                                  -- flag = {"chapter"}},
        {target = {"part 1","part i[^%l]","part one"}, flag = {"\n *part","\n *part","\n *part"}}
    }
    local i = 1
    local j = 1
    local index = 1
    local ch1Start = 0
    local upperBool = true
    local matcher = 9
    local text = {txtLower,txt}
    local tSwitch = 1
    while true do
        while true do
            if i == 6 or i == 4 then 
                tSwitch = 2
            else
                tSwitch = 1
            end
            if randID == 27827 and i == 1 then    -- for Kama Sutra
                i = 2
            end
            local a,z = string.find(text[tSwitch], ch1Test[i].target[j],index)
            local test = string.find(text[tSwitch], "\n\n-i.",index)
            if z then 
                if z > threshold then 
                    if j >= #ch1Test[i].target then
                        j = 1
                        i = i + 1
                        goto nextLoop
                    else
                        j = j + 1
                        goto nextLoop
                    end
                end
                -- Test for uppercase introduction
                local upperA, upperZ = string.find(string.sub(txt,z,z+index+200),'%l',index)
                if upperA then
                    upperBool = false
                else
                    index = z + 1
                    j = 1
                    goto nextLoop
                end
                -- Test for table of contents 
                local x = 0
                local c = 0
                local b,y = string.find(string.sub(txtLower, z, z+500), ch1Test[i].flag[j])
                if i == 6 then 
                    c,x = string.find(string.sub(text[tSwitch], z, z+1500), ch1Test[i].flag[j])
                end
                if y then 
                    index = 5 + z
                    j = 1
                elseif x and x > 0 then 
                    index = 5 + z
                    j = 1
                else
                    ch1Start = a
                    matcher = i
                    break
                end
            else
                j = j + 1
            end
            if j > #ch1Test[i].target then 
                j = 1
                break
            end
            ::nextLoop::
        end
        if ch1Start > 0 then
            break
        else
            i = i + 1
            index = 1
        end
        if i > #ch1Test then
            break
        end 
    end
    return ch1Start, matcher
end

local function findChapterBreaks(txt,matcher,allCaps)
    if matcher == 9 then 
        return {0}
    end
    local romanNums = {'I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX','XXI','XXII','XXIII','XXIV','XXV','XXVI','XXVII','XXVIII','XXIX','XXX','XXXI','XXXII','XXXIII','XXXIV','XXXV','XXXVI','XXXVII','XXXVIII','XXXIX','XL','XLI','XLII','XLIII','XLIV','XLV','XLVI','XLVII','XLVIII','XLIX','L','LI'}
    local nums = {'one','two','three','four','five','six','seven','eight','nine','ten','eleven','twleve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty','twenty-one','twenty-two','twenty-three','twenty-four','twenty-five','twenty-six','twenty-seven','twenty-eight','twenty-nine','thirty','thirty-one','thirty-two','thirty-three','thirty-four','thirty-five','thirty-six','thirty-seven','thirty-eight','thirty-nine','forty','forty-one','forty-two','forty-three','forty-four','forty-five','forty-six','forty-seven','forty-eight','forty-nine','fifty'}
    local counter = 1
    local txtLower = string.lower(txt)
    local matchers = {
        function(counter) return "\n%s*chapter" end,
        function(counter) return "\n%s*"..tostring(counter)..'[%.\n]' end,
        function(counter) return "\n%s*"..string.lower(tostring(romanNums[counter])..'[%.n]') end,
        function(counter) return "\n\n%s*"..tostring(nums[counter]) end,
        {function(counter) return "\n *act"..' '..tostring(counter) end, function(counter) return "\n *act"..' '..string.lower(tostring(romanNums[counter]..'[%.\n]')) end, function(counter) return "\n *act"..' '..tostring(nums[counter]) end},
        function(counter) return "\n\n%s*[%u %p]+\n\n+%u[ %l][ %l][ %l]" end,
        function(counter) return "\n *part" end
    }
    local chapterBreaks = {0}
    local z1 = 1
    local i = 1
    local text = {txtLower,txt}
    local tSwitch = 1
    if matcher == 8 and allCaps then 
        for _,v in ipairs(allCaps) do 
            table.insert(chapterBreaks,v)
        end
    end
    if matcher < 5 or matcher == 6 or matcher == 7 then
        while true do
            if matcher == 6 then 
                tSwitch = 2
            else
                tSwitch = 1
            end
            counter = counter + 1
            local pattern = matchers[matcher](counter)
            local match = string.find(text[tSwitch],matchers[matcher](counter),z1+20)
            if match then
                table.insert(chapterBreaks,match+1)
                z1 = match
            else
                break
            end
        end
    elseif matcher == 5 then
        tSwitch = 1
        local j = 1
        while true do
            counter = counter + 1
            local match = string.find(text[tSwitch],matchers[matcher][j](counter),z1+4)
            if match then
                table.insert(chapterBreaks,match)
                z1 = z1 + match + 4
            elseif #chapterBreaks > 1 then
                break
            else
                j = j + 1
                counter = 1
            end
            if j > #matchers[matcher] then
                break
            end
        end
    end
    return chapterBreaks
end

local function noStart(txt)
    local start1 = string.find(txt, 'START OF THE PROJECT GUTENBERG EBOOK.-\n')
    local _,start2 = string.find(txt, '\n[Bb][Yy] .-\n',start1)
    -- check for table of contents (made for Walden, 30)
    local nLines = {}
    local j = 1
    while true do
        if start2 then 
            j = string.find(string.sub(txt,start2,5000),'\n',j+1)
            if j == nil then break end
            table.insert(nLines, j)
        else
            break
        end
    end
    local prev = 1
    for i,v in ipairs(nLines) do 
        if v > prev + 50 then
            local minus = i - 3
            if minus < 1 then
                minus = 1
            end
            start2 = nLines[minus] + start2
            break
        end
        prev = v
    end
    return start2 or 1
end

local function forceChapterBreaks(text)
    local breaks = {1}
    local index = 5000
    while true do
        local _,brk = string.find(text,'%.\n+',index)
        if brk then 
            index = brk + 5000
            table.insert(breaks, brk)
            if index >= #text - 1000 then
                break
            end
        else
            break 
        end
    end
    return breaks
end

local function fallbacks(txt)
    local matcher = 9
    local startBook = 0 
    local index = 1
    local capIndexes = {}
    while true do
        -- for Ulysses (index 14)
        local _,sBook = string.find(txt,'%[ 1 %]',index)
        if sBook then 
            local _,nsBook = string.find(string.sub(txt,sBook,sBook+2000),'%[ 1 %]')
            if nsBook then
                index = sBook + nsBook - 100
            else
                startBook = sBook + 1
                break
            end
        else
            break
        end
        if index >= math.floor(#txt/10) then 
            break
        end
    end
    if startBook < 1 then
        index = 1
        -- for Importance of Being Earnest
        local sBook = string.find(txt,'\n\n-FIRST ACT[%s\n]\n',index)
        if sBook then
            startBook = sBook
        end
    end
    if startBook < 1 then
        index = 1
        -- for Dr. Jekyll
        local b = 1
        local a = 0
        local anchor = 1
        local preAnchor = 1
        local needAnchor = true
        local lineNum = 0
        local charTally = 0
        local minChar = 40
        while true do
            if b +1 >= #txt then 
                minChar = minChar - 10
                b = 1
                a = 0
                anchor = 1
                preAnchor = 1
                needAnchor = true
                lineNum = 0
                charTally = 0
            end
            a,b = string.find(txt, "[^\n]+",b+1)
            if not a then 
                print('not a')
                break 
            end
            local c = string.find(string.sub(txt,a,b),'%l')
            if c then
                if needAnchor then
                    needAnchor = false
                    anchor = a
                end
                lineNum = lineNum + 1
                charTally = charTally + b - a
                if lineNum >= 20 then
                    local test = charTally/lineNum
                    if test > minChar then 
                        break
                    else
                        lineNum = 0
                        charTally = 0
                        b = anchor + 50
                        anchor = b
                        preAnchor = b
                    end
                end
            elseif string.find(string.sub(txt,a,b),'%u') then
                preAnchor = a
                needAnchor = true
            end
        end
        b = preAnchor - 5
        local capMatches = {}
        while true do
            a,b = string.find(txt, "%f[\n]%s*%u+[%u%s%p]+%f[\n]",b+1)
            if b == nil then break end
            table.insert(capMatches, {text = string.sub(txt,a,b), index = a})
        end
        -- check for spread over full text
        local bookLen = #txt 
        local j = 1
        local bracket = bookLen/5
        for _,v in ipairs(capMatches) do
            if v.index > bracket*(j-1) and v.index < bracket*j then
                j = j + 1
            end
        end 
        if j >= 5 then
            local prev = 1
            for i,v in ipairs(capMatches) do 
                if #capMatches == 1 then
                    startBook = v.index
                    break
                end
                if  v.index > prev + 4000 then
                    if i == 1 then
                        i = 2
                    end
                    startBook = capMatches[i-1].index
                    for r = i,#capMatches do 
                        table.insert(capIndexes,capMatches[r].index-startBook)   
                    end
                    matcher = 8
                    break
                end
                if i == #capMatches then
                    startBook = v.index
                    break
                end
                prev = v.index
            end
        elseif capMatches and #capMatches > 0 and capMatches[#capMatches].index < #txt/4 then
            startBook = capMatches[#capMatches].index
        end
    end
    return startBook,matcher,capIndexes
end


local function findStart(tx,randID)
    local txt = removeWhitespace(tx)
--[[     local file = io.open('testBook.txt','w')
    io.output(file)
    io.write(txt)
    io.close(file) ]]
    local allCaps = {}
    local ch1Start, matcher = findChapterOne(txt,randID)
    --Exceptions for Ulysses,Earnest,Jekyll
    --if randNum == 14 or randNum == 21 or randNum == 24 then
    if randID == 4300 or randID == 844 or randID == 43 then
        print('randId arrived')
        ch1Start = 0
        matcher = 9
    end
    if ch1Start < 1 then
        ch1Start,matcher,allCaps = fallbacks(txt) 
        if ch1Start < 1 then
            ch1Start = noStart(txt)
        end
    end
    local text = string.sub(txt,ch1Start)
    local breaks = findChapterBreaks(text,matcher,allCaps)
    if #breaks < 2 then
        breaks = forceChapterBreaks(text)
    end
    return text, breaks
end

function getBook(inVal) 
    local reopenBool = false
    if inVal == 'reset' then
        TYPEWRITER:newBookReset()
    elseif type(inVal) == "number" and inVal > 0 then 
        reopenBool = true
    end
    local randNum = 0
    local randId = 0
    local pref = PREFS.search
    local idMatch = false
    local result = ''
    while true do 
        while true do
            print('SearchIndexSizes[pref]',SearchIndexSizes[pref])
            randNum = rng:random(1,SearchIndexSizes[pref]-1)
            print('randNum',randNum)
            print('SearchIndex[pref][randNum].gut_id',SearchIndex[pref][randNum].gut_id)
            --randNum = BOOKCOUNT
            randId = SearchIndex[pref][randNum].gut_id
            if randId == 41 or randId == 6130 or randId == 1497 then 
                goto endWhile
            end
            idMatch = false
            if USERDATA and #USERDATA > 0 then
                for _,v in ipairs(USERDATA) do
                    if tonumber(v.gut_id) == randId then
                        idMatch = true
                    end
                end
            end
            if idMatch == false then
                break
            end
            ::endWhile::
        end
        if reopenBool then
            randId = inVal 
        end
--[[         if FIRST_BOOK then
            randId = 64317
            randNum = 6
            FIRST_BOOK = false
        end
        FIRST_BOOK = true ]]
        --print('book index: ',BOOKCOUNT,'book id: ',randId)
        local txt1 = get_gutenberg_text((tonumber(randId)))
        if txt1 and type(txt1) == "string" then
            result = txt1
            break 
        end
        inVal = 0
    end
    local _,s = string.find(result, 'START OF TH[IE]S* PROJECT GUTENBERG.-\n')
    local txt = ''
    if s then 
        local result1 = string.sub(result, s+1)
        local a,z = string.find(result1, '%*+ *END OF TH[IE]S* PROJECT GUTENBERG')
        if a then 
            txt = string.sub(result1,1,a-1)
        end
    else
        txt = result
    end
--[[     local file = io.open('book_raw.txt','w')
    io.output(file)
    io.write(txt)
    io.close(file) ]]
    local text, breaks = findStart(txt,randId)
--[[     local file = io.open('book.txt','w')
    io.output(file)
    io.write(txt)
    io.close(file) ]]
    local chapterOneRaw = string.sub(text,1,breaks[2])
    local chapterOne = getByteRight(chapterOneRaw)
    local bytes,chars = checkBytes(chapterOne) 
    print('Byte count *************************************')
    print('bytes: ',bytes,'            chars: ',chars) 
    print('book index: ',BOOKCOUNT,'book id: ',randId)
    if bytes ~= chars then 
        print('try again')
        tryAgain() 
    else
        closeBook()
        if reopenBool then 
            BOOK.fullText = text 
        else
            BOOK = book(text,randId,randNum,pref,breaks,chapterOne)
            if TYPEWRITER_MODE then
                TYPEWRITER:bookReady()
            else
                BOOK:next()
            end
        end
    end
end

function tryAgain()
    getBook()
end

function checkBytes(txt) 
    local breakNum = #txt 
    local numbyte = 0
    local numbytes = 0
    for i = 1, #txt do 
        numbyte = utf8Charbytes(txt,i)
        if numbyte then 
            numbytes = numbytes + numbyte
        end
    end
    return numbytes, breakNum
end

function getByteRight(txt1)
    local breakNum = #txt1
    local tempTxtL = ''
    local tempTxtR = ''
    for i = 1, #txt1 do 
        if i >= breakNum then 
            break
        end
        local numbyte,chr = utf8Charbytes(txt1,i)
        if numbyte then
            if numbyte > 1 then 
                local subChar = '#'
                local decrement = 2
                if chr == 156 or chr == 157 then 
                    subChar = '"' 
                elseif chr == 153 or subChar == 152 then 
                    subChar = "'" 
                elseif chr == 148 then 
                    subChar = '-' 
                elseif chr == 169 then 
                    subChar = "e" 
                elseif chr == 160 then 
                    subChar = "a"
                elseif chr == 167 then 
                    subChar = 'co'
                    decrement = 1
                end
                tempTxtL = string.sub(txt1,1, i-1)
                tempTxtR = subChar..string.sub(txt1, i+3)
                txt1 = ''
                if tempTxtL and tempTxtR then
                    txt1 = tempTxtL..tempTxtR 
                elseif tempTxtL then 
                    txt1 = tempTxtL 
                else
                    txt1 = tempTxtR      
                end         
                tempTxtL = ''
                tempTxtR = ''
                breakNum = breakNum - decrement
            end
        else
            print('arrived else')
        end
    end
    return txt1
end

function utf8Charbytes (s, i)
   -- argument defaults
   i = i or 1
   local c = string.byte(s, i)
   
   -- determine bytes needed for character, based on RFC 3629
   if c > 0 and c <= 127 then
      -- UTF8-1
      return 1,c
   elseif c >= 194 and c <= 223 then
      -- UTF8-2
      local c2 = string.byte(s, i + 1)
      return 2,c2
   elseif c >= 224 and c <= 239 then
      -- UTF8-3
      local c2 = s:byte(i + 1)
      local c3 = s:byte(i + 2)
      return 3,c3
   elseif c >= 240 and c <= 244 then
      -- UTF8-4
      local c2 = s:byte(i + 1)
      local c3 = s:byte(i + 2)
      local c4 = s:byte(i + 3)
      return 4,c4
   end
end
