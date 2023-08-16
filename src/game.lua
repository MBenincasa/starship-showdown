-- Imports
local Ship = require("objects/ship")
local Checkpoint = require("objects/checkpoint")

local Game = {} -- Declaration of an empty table named "Game"
Game.__index = Game -- Set the index of the "Game" table to itself

function Game.new()
    local self = setmetatable({}, Game) -- Create a new instance of the Game class
    self.ship = Ship.new() -- Initialize the ship object using the Ship class
    self.checkpoints = { -- Initialize the list of checkpoints
        Checkpoint.new(200, 200, 1),
        Checkpoint.new(300, 600, 2),
        Checkpoint.new(640, 100, 3)
    }
    self.currentCheckpointIndex = 1 -- Set the current checkpoint index to 1
    self.lap = 1 -- Initialize lap counter to 1
    self.timer = 0 -- Initialize timer to 0
    self.isRunning = true -- Set the game to be running initially
    self.maxLaps = 3 -- Set the maximum number of laps
    self.checkpointTimes = {} -- Initialize an empty table to store checkpoint times
    self.lapTimes = {} -- Initialize an empty table to store lap times
    self.isFinished = false -- Flag to indicate if the race is finished
    return self -- Return the newly created Game instance
end

function Game:update(dt)
    if self.isRunning then
        self.ship:update(dt) -- Update the ship's state based on the delta time (dt)
        self:checkCollisions() -- Check for collisions with checkpoints
        self.timer = self.timer + dt -- Increment the timer by the delta time
    end

    if self.isFinished then
        self.isRunning = false -- Stop updating the ship when the race is finished
    end
end

function Game:draw()
    Checkpoint.draw(self.checkpoints, self.currentCheckpointIndex) -- Draw checkpoints with currentCheckpointIndex indicating the next checkpoint
    self.ship:draw() -- Draw the ship
    self.ship:debug() -- Draw debugging information for the ship

    love.graphics.setColor(1, 1, 1)

    local yOffset = 60 -- Vertical offset for lap time display
    local lineHeight = 20 -- Height of each line
    local xOffset = 10 -- Horizontal offset for lap time display

    -- Display lap times and total lap time in descending order
    for lapIndex = #self.lapTimes, 1, -1 do
        local lapTimes = self.lapTimes[lapIndex]
        local lapTimeText = "LAP " .. lapIndex .. " - "
        for checkpointIndex, time in ipairs(lapTimes) do
            lapTimeText = lapTimeText .. "T" .. checkpointIndex .. ": " .. string.format("%.3f", time) .. "s "
        end
        lapTimeText = lapTimeText .. "- TOTAL: " .. self:getTotalLapTime(lapTimes) .. "s"
        love.graphics.print(lapTimeText, xOffset, 10 + (lapIndex - 1) * lineHeight)
    end

    -- Display "Race Finished" if the race is finished
    if self.isFinished then
        love.graphics.print("Race Finished", xOffset, 720 - yOffset)
    end

    -- Display lap number in the top-right corner
    if not self.isFinished then
        love.graphics.print("Lap: " .. self.lap .. "/" .. self.maxLaps, 1280 - 120, 10)
    end
end

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

function Game:resetCheckpoints()
    for _, checkpoint in ipairs(self.checkpoints) do
        checkpoint.passed = false -- Reset the "passed" status for all checkpoints
    end
end

function Game:getTotalLapTime(lapTimes)
    local totalLapTime = 0
    for _, time in ipairs(lapTimes) do
        totalLapTime = totalLapTime + time
    end
    return string.format("%.3f", totalLapTime) -- Return the total lap time formatted to three decimal places
end

return Game