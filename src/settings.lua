-- Create a table named "Settings" to hold settings-related functions and values.
local Settings = {}

-- Initialize settings variables.
Settings.isMenuOpen = false -- Flag to track if the settings menu is open.
Settings.isMusicEnabled = true -- Flag to track if background music is enabled.

-- Define a function to draw the settings menu on the screen.
function Settings:drawSettingsMenu()
    love.graphics.setColor(1, 1, 1) -- Set text color to white.
    love.graphics.print("Settings Menu", 10, 10) -- Draw the title of the settings menu.
    love.graphics.print("1. Toggle Music: " .. (Settings.isMusicEnabled and "On" or "Off"), 10, 30) -- Display the option to toggle music on/off based on the state of isMusicEnabled.
    love.graphics.print("2. Restart Game", 10, 50) -- New option to restart the game.
    love.graphics.print("3. Exit Game", 10, 70) -- Display the option to exit the game.
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
        elseif key == "3" then
            love.event.quit() -- Exit the game when "3" is pressed.
        end
    end
end

-- Return the Settings table to make it accessible for use in other files.
return Settings
