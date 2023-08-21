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
    local angleToCheckpoint = math.atan2(dy, dx) + math.rad(90)
    local angleDifference = (angleToCheckpoint - self.ship.rotation) % (2 * math.pi)

    local speed = self.ship:getSpeed()
    if distanceToCheckpoint < 50 then
        currentCheckpointIndex = currentCheckpointIndex + 1
        if currentCheckpointIndex > #self.checkpoints then
            currentCheckpointIndex = 1
        end
        currentCheckpoint = self.checkpoints[currentCheckpointIndex]
        dx = currentCheckpoint.x - self.ship.x
        dy = currentCheckpoint.y - self.ship.y
        distanceToCheckpoint = math.sqrt(dx^2 + dy^2)
        angleToCheckpoint = math.atan2(dy, dx) + math.rad(90)
        angleDifference = (angleToCheckpoint - self.ship.rotation) % (2 * math.pi)
    end

    if (angleDifference > math.pi) then
        self.ship:rotateToLeft(dt)
    elseif (angleDifference < math.pi or angleDifference > 0) then
        self.ship:rotateToRight(dt)
    end

    if (distanceToCheckpoint < 200 and speed > 70) then
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