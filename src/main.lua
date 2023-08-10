-- Imports
local Ship = require("objects/ship")

-- Variables
local ship

-- This method is called only once at the beginning of the game's execution.
function love.load()
    love.window.setTitle("Starship Showdown")
    love.window.setMode(1280, 720)
    ship = Ship.new()
end

-- This method is called during every game cycle. It receives the parameter dt (delta time), which represents the time interval elapsed between the previous frame and the current one.
function love.update(dt)
    ship:update(dt)
end

-- This method is called immediately after love.update() within the game cycle. This is where objects, images, and any visual elements on the screen are drawn.
function love.draw()
    ship:draw()
end