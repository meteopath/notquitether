
local timer = 0

local introSound = love.audio.newSource("assets/audio/intro_no_e.wav", "static")

local titleGif = love.graphics.newImage('assets/spriteSheets/intro_no_e_sheet.png')
local titleGrid = anim8.newGrid(428, 240, titleGif:getWidth(), titleGif:getHeight())
local aniTitle = anim8.newAnimation(titleGrid('1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-5', 5, '1-5', 6, '1-5', 7, '1-5', 8, '1-5', 9, '1-5', 10, '1-5', 11, '1-5',12 ,'1-5',13, '1-5',14, '1-5',15,'1-1',16), 0.1)

local introTimer = require "libraries/hump/timer"

introSound:setVolume(0.4)

local introBool = true
function introUpdate(dt)
    if GAME_STATE == 0 then
        introTimer.update(dt) 
        if introBool then
            introBool = false
            introTimer.tween(3,WP,{red=0.53})
            introTimer.tween(4,WP,{green=1})
            introTimer.tween(4,WP,{blue=0.68})
        end
        introSound:play()
        aniTitle:update(dt)
        if timer >= 7.9 then
            GAME_STATE = 1
        end
        timer = timer + dt
    end
end

local gifRatio = 428/240

local screenRatio = love.graphics.getWidth()/love.graphics.getHeight()

local scale = 0
local x = 0
local y = 0
if gifRatio > screenRatio then
    scale = math.floor((love.graphics.getWidth()/428)*100)/100
    x = 0
    y = (love.graphics.getHeight() - 240*scale)/2
else
    scale = math.floor((love.graphics.getWidth()/240)*100)/100
    y = 0
    x = (love.graphics.getWidth() - 240*scale)/2
end

function drawIntro()
    if GAME_STATE == 0 then
        love.graphics.setColor(0.53, 1, 0.68)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        aniTitle:draw(titleGif, x, y, 0, scale)
    end
end
