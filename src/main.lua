-- Imports
love.audio = require("love.audio")
local Game = require("game")
local Settings = require("settings")

-- Variables
local game
local backgroundMusic

-- This method is called only once at the beginning of the game's execution.
function love.load()
    -- love._openConsole()
    love.window.setTitle("Starship Showdown")
    love.window.setMode(1280, 720)

    -- Loads the audio file
    backgroundMusic = love.audio.newSource("resources/background.mp3", "stream")
    backgroundMusic:setLooping(true)
    -- Start audio playback
    love.audio.play(backgroundMusic)

    game = Game.new()
end

-- This method is called during every game cycle. It receives the parameter dt (delta time), which represents the time interval elapsed between the previous frame and the current one.
function love.update(dt)
    if not Settings.isMenuOpen then
        game:update(dt) -- Update only if the settings menu is not open
    end
    backgroundMusic:setVolume(Settings.isMusicEnabled and 1 or 0)
end

-- This method is called immediately after love.update() within the game cycle. This is where objects, images, and any visual elements on the screen are drawn.
function love.draw()
    game:draw()
end

-- This function is called whenever a key is pressed.
function love.keypressed(key)
    Settings:keypressed(key) -- Delegate the key press handling to the Settings module.
end
