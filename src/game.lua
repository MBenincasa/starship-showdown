-- Imports
local Ship = require("src.objects.ship")
local Rival = require("src.objects.rival")
local Checkpoint = require("src.objects.checkpoint")
local Settings = require("src.settings")

local Game = {} -- Declaration of an empty table named "Game"
Game.__index = Game -- Set the index of the "Game" table to itself

-- Constructor for creating a new Game instance
function Game.new()
    local self = setmetatable({}, Game) -- Create a new instance of the Game class
    self.ship = Ship.new() -- Initialize the ship object using the Ship class
    self.checkpoints = { -- Initialize the list of checkpoints
        Checkpoint.new(200, 200, 1), -- Create a new checkpoint at position (200, 200) with ID 1
        Checkpoint.new(300, 600, 2), -- Create a new checkpoint at position (300, 600) with ID 2
        Checkpoint.new(640, 100, 3)  -- Create a new checkpoint at position (640, 100) with ID 3
    }
    self.rival = Rival.new(self.checkpoints) -- Initialize the rival's ship object using the Rival class
    self.currentCheckpointIndex = 1 -- Set the current checkpoint index to 1
    self.lap = 1 -- Initialize lap counter to 1
    self.rivalLap = 1 -- Initialize rival's lap counter to 1
    self.timer = 0 -- Initialize timer to 0
    self.rivalTimer = 0 -- Initialize rival's timer to 0
    self.isRunning = true -- Set the game to be running initially
    self.isRivalRunning = true -- Set the rival's game to be running initially
    self.maxLaps = 3 -- Set the maximum number of laps for the race
    self.checkpointTimes = {} -- Initialize an empty table to store checkpoint times for the ship
    self.rivalCheckpointTimes = {} -- Initialize an empty table to store checkpoint times for the rival
    self.lapTimes = {} -- Initialize an empty table to store lap times for the ship
    self.rivalLapTimes = {} -- Initialize an empty table to store lap times for the rival
    self.isFinished = false -- Flag to indicate if the ship's race is finished
    self.isRivalFinished = false -- Flag to indicate if the rival's race is finished
    return self -- Return the newly created Game instance
end

-- Update method for the Game class
function Game:update(dt)
    if self.isRunning then
        self.ship:update(dt) -- Update the ship's state based on the delta time (dt)
        self:checkCollisions() -- Check for collisions with checkpoints
        self.timer = self.timer + dt -- Increment the timer by the delta time
    end

    if self.isRivalRunning then
        self.rival:update(dt) -- Update the rival's ship
        self:checkRivalCollisions() -- Check for rival's collisions with checkpoints
        self.rivalTimer = self.rivalTimer + dt -- Increment the rival's timer by the delta time
    end

    if self.isRivalFinished then
        self.isRivalRunning = false -- Stop the rival's ship from updating when it's finished
    end

    if self.isFinished then
        self.isRunning = false -- Stop updating the ship when the race is finished
    end
end

-- Draw method for the Game class
function Game:draw()
    -- Check if the settings menu is open
    if Settings.isMenuOpen then
        Settings:drawSettingsMenu() -- If open, draw the settings menu.
    else
        Checkpoint.draw(self.checkpoints, self.currentCheckpointIndex) -- Draw checkpoints with currentCheckpointIndex indicating the next checkpoint
        self.ship:draw() -- Draw the ship
        self.rival:draw() -- Draw the rival's ship

        love.graphics.setColor(1, 1, 1)

        local yOffset = 60 -- Vertical offset for lap time display
        local lineHeight = 20 -- Height of each line
        local xOffset = 10 -- Horizontal offset for lap time display

        -- Display lap times and total lap time for Ship in descending order
        for lapIndex = #self.lapTimes, 1, -1 do
            local lapTimes = self.lapTimes[lapIndex]
            local lapTimeText = "LAP " .. lapIndex .. " - "
            for checkpointIndex, time in ipairs(lapTimes) do
                lapTimeText = lapTimeText .. "T" .. checkpointIndex .. ": " .. string.format("%.3f", time) .. "s "
            end
            lapTimeText = lapTimeText .. "- TOTAL: " .. self:getTotalLapTime(lapTimes) .. "s"
            local lapTimeX = xOffset
            local lapTimeY = 10 + (lapIndex - 1) * lineHeight
            love.graphics.print(lapTimeText, lapTimeX, lapTimeY)
        end

        -- Display lap times and total lap time for Rival in descending order
        for lapIndex = #self.rivalLapTimes, 1, -1 do
            local lapTimes = self.rivalLapTimes[lapIndex]
            local lapTimeText = "RIVAL LAP " .. lapIndex .. " - "
            for checkpointIndex, time in ipairs(lapTimes) do
                lapTimeText = lapTimeText .. "T" .. checkpointIndex .. ": " .. string.format("%.3f", time) .. "s "
            end
            lapTimeText = lapTimeText .. "- TOTAL: " .. self:getTotalLapTime(lapTimes) .. "s"
            local lapTimeWidth = love.graphics.getFont():getWidth(lapTimeText)
            local rivalLapTimeX = love.graphics.getWidth() - lapTimeWidth - xOffset
            local rivalLapTimeY = 10 + (lapIndex - 1) * lineHeight
            love.graphics.print(lapTimeText, rivalLapTimeX, rivalLapTimeY)
        end

        -- Display "Race Finished" if the race is finished
        if self.isFinished then
            love.graphics.print("Race Finished", xOffset, 720 - yOffset)
        end

        -- Display lap number in the top-center
        if not self.isFinished then
            local lapNumberText = "Lap: " .. self.lap .. "/" .. self.maxLaps
            local lapNumberWidth = love.graphics.getFont():getWidth(lapNumberText)
            local lapNumberX = (love.graphics.getWidth() - lapNumberWidth) / 2
            love.graphics.print(lapNumberText, lapNumberX, 10)
        end
    end
end

-- Method to check collisions with checkpoints for the Ship
function Game:checkCollisions()
    if self.isFinished then
        return
    end

    local currentCheckpoint = self.checkpoints[self.currentCheckpointIndex] -- Get the current checkpoint
    local distanceToCheckpoint = math.sqrt((self.ship.x - currentCheckpoint.x)^2 + (self.ship.y - currentCheckpoint.y)^2) -- Calculate the distance to the current checkpoint

    -- Check if the ship is close to the checkpoint and hasn't passed it already
    if distanceToCheckpoint <= currentCheckpoint.radius and not currentCheckpoint.passed then
        currentCheckpoint.passed = true -- Mark the checkpoint as passed

        table.insert(self.checkpointTimes, self.timer) -- Store the time taken to reach the checkpoint

        self.timer = 0 -- Reset the lap timer

        self.currentCheckpointIndex = self.currentCheckpointIndex + 1 -- Move to the next checkpoint

        if self.currentCheckpointIndex > #self.checkpoints then
            self.currentCheckpointIndex = 1 -- Wrap around to the first checkpoint if all checkpoints are passed
            self:completeLap() -- Complete a lap when all checkpoints are passed
        end
    end
end

-- Method to check collisions with checkpoints for the Rival
function Game:checkRivalCollisions()
    if self.isRivalFinished then
        return
    end

    local rivalCurrentCheckpoint = self.rival.checkpoints[self.rival.currentCheckpointIndex] -- Get the current checkpoint for the Rival

    -- Calculate distances to the checkpoints for both Ship and Rival
    local distanceToCheckpoint = math.sqrt((self.rival.ship.x - rivalCurrentCheckpoint.x)^2 + (self.rival.ship.y - rivalCurrentCheckpoint.y)^2)

    -- Check if the rival is close to the checkpoint and hasn't passed it already
    if distanceToCheckpoint <= rivalCurrentCheckpoint.radius then

        table.insert(self.rivalCheckpointTimes, self.rivalTimer) -- Store the time taken by Ship to reach the checkpoint

        self.rivalTimer = 0 -- Reset the lap timer
        self.rival.currentCheckpointIndex = self.rival.currentCheckpointIndex + 1

        if self.rival.currentCheckpointIndex > #self.rival.checkpoints then
            self.rival.currentCheckpointIndex = 1
            self:completeRivalLap()
        end
    end
end

-- Method to complete a lap for the Ship
function Game:completeLap()
    table.insert(self.lapTimes, self.checkpointTimes) -- Store the checkpoint times for the completed lap
    self.checkpointTimes = {} -- Reset checkpoint times for the next lap

    self.lap = self.lap + 1 -- Increment lap count
    self.timer = 0 -- Reset the lap timer
    self:resetCheckpoints() -- Reset checkpoint statuses for the new lap

    if self.lap > self.maxLaps then
        self.isFinished = true -- Finish the race when the maximum laps are completed
    end
end

-- Method to complete a lap for the Rival
function Game:completeRivalLap()
    table.insert(self.rivalLapTimes, self.rivalCheckpointTimes) -- Store the checkpoint times for the completed lap
    self.rivalCheckpointTimes = {} -- Reset checkpoint times for the next lap
    self.rivalLap = self.rivalLap + 1
    self.rivalTimer = 0 -- Reset the lap timer

    if self.rivalLap > self.maxLaps then
        self.isRivalFinished = true
    end
end

-- Method to reset checkpoint statuses for a new lap
function Game:resetCheckpoints()
    for _, checkpoint in ipairs(self.checkpoints) do
        checkpoint.passed = false -- Reset the "passed" status for all checkpoints
    end
end

-- Method to calculate the total lap time
function Game:getTotalLapTime(lapTimes)
    local totalLapTime = 0
    for _, time in ipairs(lapTimes) do
        totalLapTime = totalLapTime + time
    end
    return string.format("%.3f", totalLapTime) -- Return the total lap time formatted to three decimal places
end

return Game -- Return the Game table to make the class available for import and use in other files.