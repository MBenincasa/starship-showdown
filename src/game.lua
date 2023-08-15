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
        Checkpoint.new(300, 600, 2)
    }
    self.currentCheckpointIndex = 1 -- Set the current checkpoint index to 1
    self.lap = 1 -- Initialize lap counter to 1
    self.timer = 0 -- Initialize timer to 0
    self.isRunning = true -- Set the game to be running initially
    return self -- Return the newly created Game instance
end

function Game:update(dt)
    if self.isRunning then
        self.ship:update(dt) -- Update the ship's state based on the delta time (dt)
        self:checkCollisions() -- Check for collisions with checkpoints
        self.timer = self.timer + dt -- Increment the timer by the delta time
    end
end

function Game:checkCollisions()
    local currentCheckpoint = self.checkpoints[self.currentCheckpointIndex] -- Get the current checkpoint
    local distanceToCheckpoint = math.sqrt((self.ship.x - currentCheckpoint.x)^2 + (self.ship.y - currentCheckpoint.y)^2) -- Calculate the distance to the current checkpoint

    -- Check if the ship is close to the checkpoint and hasn't passed it already
    if distanceToCheckpoint <= currentCheckpoint.radius and not currentCheckpoint.passed then
        currentCheckpoint.passed = true -- Mark the checkpoint as passed

        self.currentCheckpointIndex = self.currentCheckpointIndex + 1 -- Move to the next checkpoint

        if self.currentCheckpointIndex > #self.checkpoints then
            self.currentCheckpointIndex = 1 -- Wrap around to the first checkpoint if all checkpoints are passed
        end

        -- If the ship passes the first checkpoint, complete a lap
        if self.currentCheckpointIndex == 1 then
            self:completeLap()
        end
    end
end

function Game:completeLap()
    self.lap = self.lap + 1 -- Increment lap count
    self.timer = 0 -- Reset the lap timer
    self:resetCheckpoints() -- Reset checkpoint statuses for the new lap
end

function Game:resetCheckpoints()
    for _, checkpoint in ipairs(self.checkpoints) do
        checkpoint.passed = false -- Reset the "passed" status for all checkpoints
    end
end

function Game:draw()
    Checkpoint.draw(self.checkpoints, self.currentCheckpointIndex) -- Draw checkpoints with currentCheckpointIndex indicating the next checkpoint
    self.ship:draw() -- Draw the ship
    self.ship:debug() -- Draw debugging information for the ship

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Lap: " .. self.lap, 10, 720 - 40) -- Display the lap number
    love.graphics.print("Time: " .. string.format("%.3f", self.timer) .. "s", 10, 720 - 20) -- Display the elapsed time
end

return Game

