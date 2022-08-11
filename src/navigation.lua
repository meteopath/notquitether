function settingsNav(X,Y)
    if SUBJECTS.page then
        SUBJECTS.closeButton:onClick(X,Y) 
        for _,v in ipairs(SUBJECTS.entries) do 
            v:onClick(X,Y) 
        end
        for _,v in ipairs(SUBJECTS.modals) do 
            v:modalClick(X,Y) 
        end
    elseif SET_BOOK.page then 
        SET_BOOK.closeButton:onClick(X,Y) 
        for _,v in ipairs(SET_BOOK.entries) do 
            v:onClick(X,Y) 
        end
        for _,v in ipairs(SET_BOOK.modals) do 
            v:modalClick(X,Y) 
        end
    elseif FOLDER.modals then
        for _,v in ipairs(FOLDER.entries) do
            v:onClick(X,Y)
        end
        for _,v in ipairs(FOLDER.modals) do
            v:modalClick(X,Y)  
        end
    elseif MENUS[1] then
        if #MENUS > 1 then
            MENUS[#MENUS].backButton:onClick(X,Y)
        end
        for _,v in ipairs(MENUS[#MENUS].buttons) do
            v:onClick(X,Y)
        end
    end
end

function menuKeyPress(key, newNav)
	if INFOWINDOWS and INFOWINDOWS[1] then
		for _,v in ipairs(INFOWINDOWS[#INFOWINDOWS].infoWindowButtons) do
			v:onPress(key)
		end
	elseif SUBJECTS.page then
		keyNavFolder3(SUBJECTS.entries,SUBJECTS.modals,key,newNav,SUBJECTS.closeButton,SUBJECTS,32)
	elseif SET_BOOK.page then 
		keyNavFolder2(SET_BOOK.entries,SET_BOOK.modals,key,newNav,SET_BOOK.closeButton,SET_BOOK,32)
	elseif FOLDER.modals then
		keyNavFolder(FOLDER.entries,FOLDER.modals,key,newNav,FOLDER.closeButton,FOLDER)
	elseif MENUS[1] then
		keyNavMenu(MENUS[#MENUS].buttons,key,newNav,MENUS[#MENUS].backButton,MENUS[#MENUS])
	end
end

function keyNavMenu(options,key,newNav,exit,root)
	if key == 'u' then
		if options == MENUS[1].buttons then
			hideSettings()
		else
			exit:onEnter()
		end
	end
	if key == 'm' then 
		for _,v in ipairs(options) do
			if v.cursor == true then
				if v.mCatcher then
					v:mCatcher(key)
				end
			end
		end
	end
	if key == 'k' then
		for _,v in ipairs(options) do
			if v.cursor == true then
				v:onEnter(key)
			end
		end
	end
	if key == 'l' then
		local next = false
		for i,v in ipairs(options) do
			if v.cursor == true then
				if i == #options then
					options[1].cursor = true
					v:getCursor()
				else
					if v.getCursor then
						v:getCursor()
						next = true
					end
				end
			elseif next == true then
				v.cursor = true 
				next = false
			end
		end
	end
	if key == 'j' then 
		local next = false
		local buttonCount = #options
		for i = buttonCount, 1, -1 do 
			if options[i].cursor == true then
				if i == 1 then
					options[buttonCount].cursor = true
					options[i].cursor = false
				else
					options[i].cursor = false
					next = true
				end
			elseif next == true then
				options[i].cursor = true 
				next = false
			end
		end
	end
	if key == 'i' then
		for _,v in ipairs(options) do
			v:getCursor()
		end
		options[1].cursor = true 
	end
end

function selectThis(options)
	for _,v in ipairs(options) do
		if v.cursor == true then
			v:onEnter()
		end
	end
end

function keyNavFolder3(options,modals,key,newNav,exit,root, adj)
	local adj = adj or 0
	for _,v in ipairs(SUBJECTS.modals) do
		v:onPress(key)
		v:keyTest(key)
	end
	MUGICON:keyTest(key) 
	TWICON:keyTest(key) 
end

function keyNavFolder2(options,modals,key,newNav,exit,root, adj)
	local adj = adj or 0
	for _,v in ipairs(SET_BOOK.modals) do
		v:onPress(key)
		v:keyTest(key)
	end
	MUGICON:keyTest(key) 
	TWICON:keyTest(key) 
end

function keyNavFolder(options,modals,key,newNav,exit,root, adj)
	local adj = adj or 0
	for _,v in ipairs(FOLDER.modals) do
		v:onPress(key)
		v:keyTest(key)
	end
	MUGICON:keyTest(key) 
	TWICON:keyTest(key) 
end

function scrollDown(options,modals)
    local next = false
    for i,v in ipairs(options) do
        if v.cursor == true then
            if i == #options then
                goto optionEnd
            else
				v:getCursor()
                next = true
            end
        elseif next == true then
			local bool = true
            v:getCursor(bool)
            v.inView = true
            next = false
            if v.button_y + v.height > v.drawHeight then
                -- Ensure scroll gets all of next bottom button onscreen
                local yBump = v.button_y + v.height - v.drawHeight 
                for j,w in ipairs(options) do
                    w.button_y = w.button_y - yBump
                    w.text_y = w.text_y - yBump
                    if w.button_y < w.top then
                        w.inView = false
                    end
                end
                -- Test whether top onscreen button fully displayed
                local nextTest = false
                local yBump2 = 0
                for j,w in ipairs(options) do 
                    if nextTest == true and w.button_y >= w.top then
                        yBump2 = w.button_y - w.top
                        goto yBump2Start
                    elseif w.button_y < w.top then
                        nextTest = true 
                    end
                end
                goto yBump2End
                ::yBump2Start::
                -- Bump buttons up so that partially displayed top button bumped offscreen
                for j,w in ipairs(options) do
                    w.button_y = w.button_y - yBump2
                    w.text_y = w.text_y - yBump2
                    if w.button_y < w.top then
                        w.inView = false
                    elseif w.button_y + w.height > w.drawHeight then 
                        w.inView = false
                    else
                        w.inView = true
                    end
                end
                ::yBump2End::
            end
        end
    end
	local noSleep = true
	if options and options[1] and options[1].cursor then
		for _,v in ipairs(modals) do
			v:toSleep('first')
			noSleep = false
		end
	end
	if options and options[#options] and options[#options].cursor then
		for _,v in ipairs(modals) do
			v:toSleep('last')
			noSleep = false
		end
	end
	if noSleep then
		for _,w in ipairs(modals) do
			w:toSleep('noSleep')
		end
	end
    ::optionEnd::
end

function navSelect(inVal)
    local options
    if inVal == 'BOOK' then
        options = SET_BOOK.entries        
    elseif inVal == 'FOLDER' then
        options = FOLDER.entries
    end
    for _,v in ipairs(options) do
        if v.cursor then
            v:onEnter()
        end
    end
end

function franzeSubject(inVal)
    if inVal == 'SUBJECT' then
        for _,v in ipairs(SUBJECT.subjects) do
            if v.cursor then
                getFranzegram(v.text)
            end
        end        
    end
end
    

function scrollUp(options,modals)
    local next = false
    local buttonCount = #options
    for i = buttonCount, 1, -1 do 
        if options[i].cursor == true then
            if i == 1 then
                goto optionEnd2
            else
                options[i]:getCursor()
                next = true
            end
            ::optionEnd2::
        elseif next == true then
            options[i].cursor = true 
            next = false
            if options[i].button_y < options[i].top then
                local yBump = options[i].top - options[i].button_y
                for j,w in ipairs(options) do
                    w.button_y = w.button_y + yBump
                    w.text_y = w.text_y + yBump
                    if w.button_y >= w.top then
                        w.inView = true
                    end
                    if w.button_y + w.height >= w.drawHeight then 
                        w.inView = false
                    end
                end
            end
        end
    end
	local noSleep = true
	for _,v in ipairs(options) do
		if v.first and v.cursor then
			for _,w in ipairs(modals) do
				w:toSleep('first')
				noSleep = false
			end
		elseif v.last and v.cursor then
			for _,w in ipairs(modals) do
				w:toSleep('last')
				noSleep = false
			end
		end
	end
	if noSleep then
		for _,w in ipairs(modals) do
			w:toSleep('noSleep')
		end
	end
end

function readerScroll(inVal)
    local options
    if inVal == 'BOOK.textSeen' then
        options = USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter]      
    end
    for i,v in ipairs(options) do
        if v.cursor == true then
            if i == #options then
				local bool = false
                v:getCursor(bool,key)
                options[1].cursor = true
                for j,w in ipairs(options) do
                    if w.cursor == true then
                        w:scrollOn()
                    else
                        w:scrollOff()
                    end
                end
            else
				local bool = false
                v:getCursor(bool,key)
                next = true
            end
        elseif next == true then
			local bool = true
            v:getCursor(bool,key) 
            next = false
            for j,w in ipairs(options) do
                if w.cursor == true then
                    w:scrollOn()
                else
                    w:scrollOff()
                end
            end
        end
    end
end

function readerNav(option, modals,key,newNav,exit)
	local options = {}
	if option == 'textSeen' then 
		options = USERDATA[SET_BOOK.index].textSeen[USERDATA[SET_BOOK.index].textSeenChapter] 
	else 
		options = option 
	end
	local next = false
	if key == 'l' then
		for i,v in ipairs(options) do
			if v.cursor == true then
				if i == #options then
					local bool = false
					--textSeenChapterForward()
					v:getCursor(bool,key)
					goto optionEnd
				else
					local bool = false
					v:getCursor(bool,key)
					next = true
				end
				::optionEnd::
			elseif next == true then
				local bool = true
				v:getCursor(bool,key) 
				next = false
				for j,w in ipairs(options) do
					if w.cursor == true then
						w:scrollOn()
					else
						w:scrollOff()
					end
				end
			end
		end
	end
	if key == 'j' then 
		local next = false
		local buttonCount = #options
		for i = buttonCount, 1, -1 do 
			if options[i].cursor == true then
				if i == 1 and USERDATA[SET_BOOK.index].textSeenChapter > 1 then
					print('navigation textSeenChapterBack called')
					textSeenChapterBack()
				else
					options[i].cursor = false
					next = true
				end
			elseif next == true then
				options[i].cursor = true 
				next = false
				for j,w in ipairs(options) do
					if w.cursor == true then
						w:scrollOn()
					else
						w:scrollOff()
					end
				end
			elseif i == #options then
				local cursor = 0 
				for j,w in ipairs(options) do 
					if w.cursor then
						cursor = j
					end 
				end
				if cursor == 0 then 
					options[i-1].cursor = true 
					for _,w in ipairs(options) do
						if w.cursor == true then
							w:scrollOn()
						else
							w:scrollOff()
						end
					end
					goto optionEnd2
				end
			end
		end
		::optionEnd2::
	end
	if key == 'k' then
		getMoreTextSeen(options[1].bookIndex,options[1].chNum)
		textSeenChapterForward()
	end
	local noSleep = true
	for _,v in ipairs(options) do
		if v.first and v.cursor and USERDATA[SET_BOOK.index].textSeenChapter == 1 then
			for _,w in ipairs(modals) do
				w:toSleep('first')
				noSleep = false
			end
		elseif v.last and v.cursor and USERDATA[SET_BOOK.index].textSeenChapter == #USERDATA[SET_BOOK.index].textSeen then
			for _,w in ipairs(modals) do
				if w.letter == 'l' then
					w:toSleep('last')
				end
				noSleep = false
			end
		end
	end
	if noSleep then
		for _,w in ipairs(modals) do
			w:toSleep('noSleep')
		end
	end
end