-- Create a table named "Settings" to hold settings-related functions and values.
local Settings = {}

-- Initialize settings variables.
Settings.isMenuOpen = false -- Flag to track if the settings menu is open.
Settings.isMusicEnabled = true -- Flag to track if background music is enabled.

-- Define a function to draw the settings menu on the screen.
function Settings:drawSettingsMenu()
    love.graphics.setColor(1, 1, 1) -- Set text color to white.

    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local menuTitle = "Settings Menu"
    local optionToggleMusic = "1. Toggle Music: " .. (Settings.isMusicEnabled and "On" or "Off")
    local optionRestartGame = "2. Restart Game"
    local optionExitGame = "3. Exit Game"

    -- Calculate text dimensions
    local textHeight = love.graphics.getFont():getHeight()
    local titleWidth = love.graphics.getFont():getWidth(menuTitle)
    local optionWidth = math.max(
        love.graphics.getFont():getWidth(optionToggleMusic),
        love.graphics.getFont():getWidth(optionRestartGame),
        love.graphics.getFont():getWidth(optionExitGame)
    )

    -- Calculate positions for centering
    local titleX = (windowWidth - titleWidth) / 2
    local startY = (windowHeight - textHeight * 3) / 2 -- Center vertically

    love.graphics.print(menuTitle, titleX, startY) -- Draw the title of the settings menu.
    love.graphics.print(optionToggleMusic, (windowWidth - optionWidth) / 2, startY + textHeight) -- Display the option to toggle music on/off.
    love.graphics.print(optionRestartGame, (windowWidth - optionWidth) / 2, startY + textHeight * 2) -- Display the option to restart the game.
    love.graphics.print(optionExitGame, (windowWidth - optionWidth) / 2, startY + textHeight * 3) -- Display the option to exit the game.
end

-- Define a function to handle key presses for settings.
function Settings:keypressed(key)
    if key == "escape" then
        Settings.isMenuOpen = not Settings.isMenuOpen -- Toggle the settings menu open/close when "Esc" is pressed.
    elseif Settings.isMenuOpen then
        -- If the settings menu is open:
        if key == "1" then
            Settings.isMusicEnabled = not Settings.isMusicEnabled -- Toggle music on/off when "1" is pressed.
        elseif key == "2" then
            love.audio.stop() -- Stop the background music when music is disabled.
            love.load() -- Restart the game when "2" is pressed.
            Settings.isMenuOpen = false
        elseif key == "3" then
            love.event.quit() -- Exit the game when "3" is pressed.
        end
    end
end

-- Return the Settings table to make it accessible for use in other files.
return Settings
