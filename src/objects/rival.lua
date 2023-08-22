local Ship = require("src.objects.ship")

local Rival = {} -- Declare an empty table named "Rival"
Rival.__index = Rival -- Set the index of the "Rival" table to itself

-- Constructor for creating a new Rival instance
function Rival.new(checkpoints)
    local self = setmetatable({}, Rival)
    self.checkpoints = checkpoints -- List of checkpoints to follow
    self.currentCheckpointIndex = 1 -- Current checkpoint index
    self.ship = Ship.new() -- Create a new ship instance for the rival
    self.color = {1, 0, 0} -- Set the color of the rival's ship
    return self
end

-- Update method for the Rival class
function Rival:update(dt)
    local currentCheckpoint = self.checkpoints[self.currentCheckpointIndex] -- Get the current checkpoint
    local currentCheckpointIndex = self.currentCheckpointIndex
    local dx = currentCheckpoint.x - self.ship.x
    local dy = currentCheckpoint.y - self.ship.y
    local distanceToCheckpoint = math.sqrt(dx^2 + dy^2)
    local angleToCheckpoint = math.atan2(dy, dx) + math.rad(90) -- Calculate the angle to the current checkpoint
    local angleToDirection = math.atan2(self.ship.velocity.y, self.ship.velocity.x) + math.rad(90) -- Calculate the angle to the ship's velocity direction
    local anglePositionDifference = (angleToCheckpoint - self.ship.rotation) % (2 * math.pi)  -- Calculate the angle difference between the ship's current rotation and the checkpoint
    local angleDirectionDifference = (angleToCheckpoint - angleToDirection) % (2 * math.pi) -- Calculate the angle difference between the checkpoint and the ship's velocity direction
    local speed = self.ship:getSpeed()

    -- When the distance to the checkpoint is small and the ship's speed is high, adjust orientation
    if distanceToCheckpoint < 310 and distanceToCheckpoint >= 40 and speed > 90 then
        if (angleDirectionDifference > math.pi) then
            self.ship:rotateToLeft(dt)
        elseif (angleDirectionDifference < math.pi or angleDirectionDifference > 0) then
            self.ship:rotateToRight(dt)
        end
    -- When close to the checkpoint, move to the next checkpoint
    elseif distanceToCheckpoint < 43 then
        currentCheckpointIndex = currentCheckpointIndex + 1
        if currentCheckpointIndex > #self.checkpoints then
            currentCheckpointIndex = 1
        end
        currentCheckpoint = self.checkpoints[currentCheckpointIndex]
        dx = currentCheckpoint.x - self.ship.x
        dy = currentCheckpoint.y - self.ship.y
        distanceToCheckpoint = math.sqrt(dx^2 + dy^2)
        angleToCheckpoint = math.atan2(dy, dx) + math.rad(90)
        anglePositionDifference = (angleToCheckpoint - self.ship.rotation) % (2 * math.pi)
        if (anglePositionDifference > math.pi) then
            self.ship:rotateToLeft(dt)
        elseif (anglePositionDifference < math.pi or anglePositionDifference > 0) then
            self.ship:rotateToRight(dt)
        end
    else
        -- Adjust orientation based on the angle between current orientation and desired direction
        if (anglePositionDifference > math.pi) then
            self.ship:rotateToLeft(dt)
        elseif (anglePositionDifference < math.pi or anglePositionDifference > 0) then
            self.ship:rotateToRight(dt)
        end
    end

    -- Apply braking or acceleration based on distance and speed
    if ((distanceToCheckpoint < 170 and distanceToCheckpoint >= 70 and speed > 110) or (distanceToCheckpoint < 70 and speed > 60)) then
        self.ship:brake(dt)
    else
        self.ship:accelerate(dt)
    end

    self.ship:calculateNextPosition(dt)
end

-- Draw method for the Rival class
function Rival:draw()
    love.graphics.setColor(self.color) -- Set the drawing color to the rival's color
    self.ship:draw() -- Draw the rival's ship using the Ship's draw method
    love.graphics.setColor(1, 1, 1) -- Reset the drawing color to white
end

return Rival -- Return the Rival table to make the class available for import and use in other files.