function startUp()
	rng = love.math.newRandomGenerator(os.time())
	Timer = require "libraries/hump/timer"
	Class = require "libraries/hump/class"
	anim8 = require 'libraries/anim8/anim8'

	TEST = 0

	COUNTER = 0

	FONT = {
		--courier (24 pt) is 57char per 800px, or 14.04px/char
		courier = love.graphics.newFont('assets/fonts/CourierPrime-Regular.ttf', 24),
		--courierS (16 pt) is 80 char per 800px, or 10px/char
		courierS = love.graphics.newFont('assets/fonts/CourierPrime-Regular.ttf', 16),
		--courierM (20pt) is 66.5char per 800px, or 12.03
		courierM = love.graphics.newFont('assets/fonts/CourierPrime-Regular.ttf', 20),
		--about 27.66 char per 800px or 28.9px/char
		--midpoint about x+14,y+24, r about 30
		courierXL = love.graphics.newFont('assets/fonts/CourierPrime-Regular.ttf', 32),
		courierXXL = love.graphics.newFont('assets/fonts/CourierPrime-Regular.ttf', 48),
		robotoL = love.graphics.newFont('assets/fonts/Roboto-Regular.ttf', 24),
		robotoM = love.graphics.newFont('assets/fonts/Roboto-Regular.ttf', 20),
		roboto = love.graphics.newFont('assets/fonts/Roboto-Regular.ttf', 16),
		--noto = love.graphics.newFont('assets/fonts/NotoSansSymbols-Light.ttf', 40),
		rubik = love.graphics.newFont('assets/fonts/Rubik-ExtraBold.ttf',36),
		notoBlack = love.graphics.newFont('assets/fonts/NotoSansMono-Black.ttf', 32),
		notoBlackS = love.graphics.newFont('assets/fonts/NotoSansMono-Black.ttf', 24),
		--TT2020E 32 pt is about 44char per 800px or 18.2px/char
		--TT2020E = love.graphics.newFont('assets/fonts/TT2020StyleE-0WvDG.ttf', 32)
	}

	ICONS = {
		key = love.graphics.newImage('assets/icons/Kicon.png'),
		mug = love.graphics.newImage('assets/icons/mug2.png'),
		mugShadow = love.graphics.newImage('assets/icons/mug2_shadow.png'),
		twYes = love.graphics.newImage('assets/icons/tw_icon_yes.png'),
		twNo = love.graphics.newImage('assets/icons/tw_icon_no.png'),
		twShadow = love.graphics.newImage('assets/icons/tw_icon_shadow2.png'),
		info = love.graphics.newImage('assets/icons/info3.png'),
		check = love.graphics.newImage('assets/icons/check.png'),
		arrowUp = love.graphics.newImage('assets/icons/arrowUp2.png'),
		upArrow = love.graphics.newImage('assets/icons/upArrow.png'),
		downArrow = love.graphics.newImage('assets/icons/downArrow.png')
	}


	currentBook = {}

	fullBookWait = false

	--Make index table, SearchIndex, with six tables, each ordered by dls desc
	local binser = require 'binser.binser'
	SearchIndex = {}
	local temp = love.filesystem.read('gutenbergIndexes/lookup5000plusSer.txt')
	local temp2 = binser.deserialize(temp)
	table.insert(SearchIndex, temp2[1])
	temp = {}
	temp2 = {}
	temp = love.filesystem.read('gutenbergIndexes/lookup1000to5000Ser.txt')
	temp2 = binser.deserialize(temp)
	table.insert(SearchIndex, temp2[1])
	temp = {}
	temp2 = {}
	temp = love.filesystem.read('gutenbergIndexes/lookup100to1000Ser.txt')
	temp2 = binser.deserialize(temp)
	table.insert(SearchIndex, temp2[1])
	temp = {}
	temp2 = {}
	temp = love.filesystem.read('gutenbergIndexes/lookup5minusSer.txt')
	temp2 = binser.deserialize(temp)
	table.insert(SearchIndex, temp2[1])
	temp = {}
	temp2 = {}
	temp = love.filesystem.read('gutenbergIndexes/lookupYear2022Ser.txt')
	temp2 = binser.deserialize(temp)
	table.insert(SearchIndex, temp2[1])
	temp = {}
	temp2 = {}
	temp = love.filesystem.read('gutenbergIndexes/lookupYear2021Ser.txt')
	temp2 = binser.deserialize(temp)
	table.insert(SearchIndex, temp2[1])

	SearchIndexSizes = {80,426,5050,7294,441,2799}

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
	require ('Settings')
	require ('textPrep')
	require ('navigation')
	require ('infoPopup')
	require ('typewriter')
	require ('bookManager')
	require ('eval')
	require ('icons')
	require ('read')
	require ('explainer')
	require ('intro')

	TWICON = getTwIcon()
	TWICON:toTw('first')
	MUGICON = getMugIcon()
	TYPEWRITER = makeType()


	--profiler setup:
	--love.profiler.start()

	love.frame = 0

	getBook()
end
