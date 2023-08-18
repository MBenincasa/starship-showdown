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

    local dx = currentCheckpoint.x - self.ship.x
    local dy = currentCheckpoint.y - self.ship.y
    local distanceToCheckpoint = math.sqrt(dx^2 + dy^2)
    local angleToCheckpoint = math.atan2(dy, dx) + math.rad(90)
    local angleDifference = (angleToCheckpoint - self.ship.rotation) % (2 * math.pi)
    local turnSpeed = math.rad(100) -- Rival's turning speed (in radians per second)

    if angleDifference > math.pi or angleDifference < 0 then
        self.ship.rotation = self.ship.rotation - turnSpeed * dt
    elseif angleDifference < -math.pi or angleDifference > 0 then
        self.ship.rotation = self.ship.rotation + turnSpeed * dt
    end

    local speed = self.ship:getSpeed()
    if distanceToCheckpoint > 100 or speed < 50 then
        local acceleration = self.ship.acceleration * dt
        -- Calculate acceleration along the x and y axes using trigonometric functions
        local accelerationX = math.sin(self.ship.rotation) * acceleration
        local accelerationY = -math.cos(self.ship.rotation) * acceleration
        -- Update x and y velocity of the ship with calculated acceleration
        self.ship.velocity.x = self.ship.velocity.x + accelerationX
        self.ship.velocity.y = self.ship.velocity.y + accelerationY
    end
    -- Calculate friction based on current velocity (always present)
    local frictionX = -self.ship.velocity.x * self.ship.frictionCoefficient
    local frictionY = -self.ship.velocity.y * self.ship.frictionCoefficient
    -- Add friction to velocity
    self.ship.velocity.x = self.ship.velocity.x + frictionX * dt
    self.ship.velocity.y = self.ship.velocity.y + frictionY * dt

    local minSpeed = 0 -- Limit the minimum speed due to friction
    -- Calculate the total speed (magnitude of the velocity vector)
    if speed < minSpeed then
        self.ship.velocity.x = 0
        self.ship.velocity.y = 0
    end

    -- If the speed is higher than the maximum allowed speed, reduce the speed to a fraction of the maximum speed
    if speed > self.ship.maxSpeed then
        local scaleFactor = self.ship.maxSpeed / speed
        self.ship.velocity.x = self.ship.velocity.x * scaleFactor
        self.ship.velocity.y = self.ship.velocity.y * scaleFactor
    end

    -- Update the ship's x and y position based on the current velocity
    self.ship.x = self.ship.x + self.ship.velocity.x * dt
    self.ship.y = self.ship.y + self.ship.velocity.y * dt
end

-- Draw method for the Rival class
function Rival:draw()
    love.graphics.setColor(self.color) -- Set the drawing color to the rival's color
    self.ship:draw() -- Draw the rival's ship using the Ship's draw method
    love.graphics.setColor(1, 1, 1) -- Reset the drawing color to white
end

return Rival -- Return the Rival table to make the class available for import and use in other files.