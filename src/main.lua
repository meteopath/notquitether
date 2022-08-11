rng = love.math.newRandomGenerator(os.time())
Timer = require "libraries/hump/timer"
Class = require "libraries/hump/class"
anim8 = require 'libraries/anim8/anim8'

TEST = 0
COUNTER = 0

MouseX = 0
MouseY = 0

--Globals 
--for toggling highlight control mouse/keyboard
KEYBOOL = false
MOUSEBOOL = false
NAVSWITCH = true
GUTCHECKLIST = {}
USERDATA = {}
BOOK = {}

-- (Responsive Code from Jasoco) Set up some globals to start with
DRAW_WIDTH	= 800
DRAW_HEIGHT	= 600
CANVAS_MODE = false
SCISSOR_MODE = false

GAME_LOOP = 1
GAME_STATE = 0	

EXPLAINER = {}

local memCounter = 0

-- wallpaper:
WP = {
	left = love.graphics.newImage('assets/wallpaper/wallpaper_L.png'),
	right = love.graphics.newImage('assets/wallpaper/wallpaper_R.png'),
	top = love.graphics.newImage('assets/wallpaper/wallpaper_T.png'),
	bottom = love.graphics.newImage('assets/wallpaper/wallpaper_B.png'),
	opacity = 0,
	red = 0.9,
	green = 0.9,
	blue = 1
}

function love.load()
	TYPEWRITER_MODE = true
	GAME_LOOP = 1
    -- (Responsive Code/Jasoco) Set up the window. Fullscreen Type is "desktop" which will resize the actual content
	-- instead of changing the screen resolution if fullscreen is enabled. 
    local success = love.window.setMode( 1280, 720, {
        resizable = true,
        fullscreentype = "desktop",
        highdpi = true
    } )
	love.resize()
	require ('intro')
	require ('load') 
	
	bookMark = 0

	--profiler setup:
	--love.profiler.start()

	love.frame = 0

	fullBookTimer = 0
end

local startTwBool = true
local drape = {
	r = {x=0,w=DRAW_WIDTH},
	l = {x=0,w=DRAW_WIDTH},
	opacity = 0
}

local startUpBool = true 

function love.update(dt)
	if GAME_STATE == 0 then
		introUpdate(dt)
		if startUpBool then
			startUpBool = false
			startUp()
		end
	end
	if GAME_STATE == 1 then
		if startTwBool then 
			TYPEWRITER:runIntro('new')
			startTwBool = false
		end
	    settingsUpdtate(dt)
		if TYPEWRITER_MODE then
			typewriterUpdate(dt)
		else
			Timer.update(dt)
		end
	elseif GAME_STATE == 2 then
		evalUpdate(dt)
		settingsUpdtate(dt)
	end
	if settingsPage and TYPEWRITER_MODE then
		Timer.update(dt*PREFS.speed)
	end
--[[ 	-- profiler generates a report every 100 frames
	love.frame = love.frame + 1
	if love.frame%100 == 0 then
		love.report = love.profiler.report(10)
		love.profiler.reset()
		love.profiler.start()
	end ]]

	if not TYPEWRITER_MODE and not showSettingsPage then
		for _,v in ipairs(READER.readButtons) do
			v:onHover(dt)
		end
	end

	memCounter = memCounter + 1 
	if memCounter >= 300 then 
		print('Mem (MB)', math.ceil(collectgarbage('count')/100)/10)
		memCounter = 0 
	end
	collectgarbage("collect")
	
end

local leftOff = 0
local topOff = 0
local offsetCounter = 0
local offsetBool = true
function love.draw()
	-- Set the scissor
	if SCISSOR_MODE then
		love.graphics.setScissor(LEFT_OFFSET, TOP_OFFSET, DRAW_WIDTH * DRAW_SCALE, DRAW_HEIGHT * DRAW_SCALE)
	end

	if CANVAS_MODE then
		print('Canvas mode')
        love.graphics.clear()
		MY_CANVAS:renderTo(drawAllTheThings)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(MY_CANVAS, LEFT_OFFSET, TOP_OFFSET, 0, DRAW_SCALE, DRAW_SCALE)
		love.graphics.rectangle('fill', 0,0,LEFT_OFFSET, love.graphics.getHeight())
	else
		-- start translate
		love.graphics.push()
		love.graphics.translate(LEFT_OFFSET, TOP_OFFSET)
		love.graphics.scale(DRAW_SCALE)

		drawAllTheThings()

		-- end translate
		love.graphics.pop()
	end
	love.graphics.setColor(WP.red,WP.green,WP.blue)
	love.graphics.rectangle('fill', 0,0,LEFT_OFFSET, love.graphics.getHeight())
	love.graphics.rectangle('fill', 0,0, love.graphics.getWidth(), TOP_OFFSET)
	love.graphics.rectangle('fill', LEFT_OFFSET+(DRAW_WIDTH*DRAW_SCALE),0,love.graphics.getWidth()-LEFT_OFFSET+(DRAW_WIDTH*DRAW_SCALE),love.graphics.getHeight())
	love.graphics.rectangle('fill', 0, TOP_OFFSET+(DRAW_HEIGHT*DRAW_SCALE),love.graphics.getWidth(),love.graphics.getHeight()-TOP_OFFSET+(DRAW_HEIGHT*DRAW_SCALE))
	love.graphics.setColor(1,1,1)
    -- Reset the Scissor
	love.graphics.setScissor()

	if GAME_STATE > 0 and introBool then
		introBool = false
		WP.red = 0.9 
		WP.blue = 1
		WP.green = 0.9
	end

	if GAME_STATE > 0 and leftOff == LEFT_OFFSET and topOff == TOP_OFFSET then
		offsetCounter = offsetCounter + 1
	elseif GAME_STATE > 0 then
		offsetCounter = 0
		offsetBool = true
		leftOff = LEFT_OFFSET
		topOff = TOP_OFFSET
		WP.opacity = 0
		WP.red = 0.9 
		WP.blue = 1
		WP.green = 0.9
	end
	
	--Wallpaper
	if offsetCounter > 150 then
		if offsetBool then
			offsetBool = false
			Timer.tween(3,WP,{opacity=0.3})
			Timer.tween(1,WP,{red=1})
			Timer.tween(1,WP,{green=1})
			Timer.tween(1,WP,{blue=1})
		end
		love.graphics.setColor(1,1,1,WP.opacity)
		love.graphics.draw(WP.left,LEFT_OFFSET-500,TOP_OFFSET)
		love.graphics.draw(WP.right,LEFT_OFFSET+(DRAW_WIDTH*DRAW_SCALE),TOP_OFFSET)
		love.graphics.draw(WP.top,LEFT_OFFSET,TOP_OFFSET-400)
		love.graphics.draw(WP.bottom,LEFT_OFFSET,TOP_OFFSET+(DRAW_HEIGHT*DRAW_SCALE))
	end

	if GAME_STATE == 0 then
		drawIntro()
	end

end

-- (Responsive Code)
function love.resize(w, h)
	local w = w or love.graphics.getWidth()
	local h = h or love.graphics.getHeight()
	SCALE_HORIZONTAL, SCALE_VERTICAL = w / DRAW_WIDTH, h / DRAW_HEIGHT
    local aspect_game = w / h
	local aspect_window = DRAW_WIDTH / DRAW_HEIGHT
	if aspect_window <= aspect_game then
		DRAW_SCALE = SCALE_VERTICAL
	else
		DRAW_SCALE = SCALE_HORIZONTAL
	end
	LEFT_OFFSET	= (w - (DRAW_WIDTH * DRAW_SCALE)) / 2
	TOP_OFFSET	= (h - (DRAW_HEIGHT * DRAW_SCALE)) / 2
    PIXEL_SCALE = love.window.getDPIScale()
end

function drawAllTheThings()
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill", 0, 0, DRAW_WIDTH, DRAW_HEIGHT)
	love.graphics.setColor(1,0,0)
	love.graphics.setFont(FONT.courierS)
	love.graphics.print('MouseX '..math.floor(MouseX), 0,0)
	love.graphics.print('MouseY '..math.floor(MouseY), 0,15)
	love.graphics.setColor(1,1,1)
	if TYPEWRITER_MODE then
		drawTypewriter()
		drawEval()
	else
		drawReader()
	end
	drawSettings()

	TWICON:draw()
	MUGICON:draw()
    TWICON:draw()
	COUNTER = COUNTER + 1
	if EXPLAINER and EXPLAINER.texts then 
		EXPLAINER:draw()
	end
	-- profiler prints the report
	love.graphics.setColor(1,0,0)
	TEST = TEST+1/60
 	love.graphics.setColor(1,1,1)
end

function love.keypressed(key)
	if GAME_STATE > 0 then 
		if INFOWINDOWS and INFOWINDOWS[1] then
			print('infoWindows')
		elseif INFO and INFO.keys then
			print('info.keys')
		elseif EXPLAINER and EXPLAINER.texts then
			EXPLAINER:interrupt()
			Timer.cancel(TYPEWRITER.explainerButton.handle)
			Timer.after(0.3,function()
				EXPLAINER = {}
			end)
			print('explainer.texts')
		else
			TWICON:onPress(key) 
			MUGICON:onPress(key)
		end
		KEYBOOL = true
		if showSettingsPage then
			menuKeyPress(key, newNav)
			if MUGICON.explainer and key == 'k' and MUGICON.explainer.interrupt then 
				MUGICON.explainer:interrupt()
			end
		elseif TYPEWRITER_MODE then
			if GAME_STATE == 1 then
				TYPEWRITER:onPress(key)
			elseif DEALER and DEALER.header then
				DEALER.header:onPress(key)
			elseif TRASHER and TRASHER.targetGo then
				TRASHER:onPress(key)
			end
		else
			for _,v in ipairs(READER.readButtons) do
				v:onPress(key)
				v:keyTest(key)
			end 
			print('arrived main keypressed else')
			TWICON:keyTest(key) 
			MUGICON:keyTest(key) 
		end
		if key == '5' then
			if BOOK and BOOK.link then
				love.system.openURL(BOOK.link)
			end
		end
	end
end

function love.mousepressed(x, y)
	if GAME_STATE > 0 then 
		local X = (x-LEFT_OFFSET)/DRAW_SCALE
		local Y = (y-TOP_OFFSET)/DRAW_SCALE
		TWICON:onClick(X,Y)
		MUGICON:onClick(X,Y)

		if INFOWINDOWS and INFOWINDOWS[1] and INFOWINDOWS[#INFOWINDOWS].infoWindowButtons then
			for _,v in ipairs(INFOWINDOWS[#INFOWINDOWS].infoWindowButtons) do 
				v:onClick(X,Y) 
			end 
		elseif SUBJECTS.page then
			for _,v in ipairs(SUBJECTS.entries) do
				v:onClick(X,Y)
			end
			for _,v in ipairs(SUBJECTS.modals) do
				v:modalClick(X,Y)
			end
		elseif SET_BOOK.page then 
			MOUSEPRESSEDARRIVED = MOUSEPRESSEDARRIVED + 1
			for _,v in ipairs(SET_BOOK.entries) do
				v:onClick(X,Y)
			end
			for _,v in ipairs(SET_BOOK.modals) do
				v:modalClick(X,Y)
			end
		elseif FOLDER and FOLDER.entries then
			for _,v in ipairs(FOLDER.entries) do
				v:onClick(X,Y)
			end
			for _,v in ipairs(FOLDER.modals) do
				v:modalClick(X,Y)
			end
		elseif MENUS[1] then
			MENUS[#MENUS].backButton:onClick(X,Y)
			for _,v in ipairs(MENUS[#MENUS].buttons) do
				v:onClick(X,Y)
			end
		elseif TYPEWRITER_MODE then
			if GAME_STATE == 1 then 
				TYPEWRITER.explainerButton:modalClick(X,Y)
			end
			if DEALER and DEALER.header then
				DEALER.header:onClick(X,Y)
			elseif TRASHER and TRASHER.targetGo then
				TRASHER:onClick(X,Y)
			end
		else
			for _,v in ipairs(READER.readButtons) do
				v:modalClick(X,Y)
			end
		end
		MouseX = (x-LEFT_OFFSET)/DRAW_SCALE
		MouseY = (y-TOP_OFFSET)/DRAW_SCALE
	end
end
