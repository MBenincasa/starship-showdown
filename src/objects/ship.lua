local Ship = {} -- Declaration of an empty table named "Ship"
Ship.__index = Ship -- Set the index of the "Ship" table to itself

function Ship.new(x, y)
    local self = setmetatable({}, Ship) -- Create a new instance (object) of the Ship class
    self.x = x or 640
    self.y = y or 600
    self.velocity = { x = 0, y = 0 } -- Velocity vector
    self.acceleration = 200 -- Ship acceleration
    self.maxSpeed = 300 -- Maximum speed of the ship
    self.rotation = 0 -- Rotation angle of the ship in radians
    self.frictionCoefficient = 0.3 -- Friction coefficient
    return self
end

-- This update method defines the update behavior of the ship
function Ship:update(dt)
    if love.keyboard.isDown("left", "a") then
        self.rotation = self.rotation - math.rad(100) * dt -- Rotates the ship to the left by subtracting a certain angle in radians
    elseif love.keyboard.isDown("right", "d") then
        self.rotation = self.rotation + math.rad(100) * dt -- Rotates the ship to the right by adding a certain angle in radians
    end

    if love.keyboard.isDown("up", "w") then
        -- Calculate acceleration multiplied by delta time (dt)
        local acceleration = self.acceleration * dt
        -- Calculate acceleration along the x and y axes using trigonometric functions
        local accelerationX = math.sin(self.rotation) * acceleration
        local accelerationY = -math.cos(self.rotation) * acceleration
        -- Updates x and y velocity of ship with calculated acceleration
        self.velocity.x = self.velocity.x + accelerationX
        self.velocity.y = self.velocity.y + accelerationY
    elseif love.keyboard.isDown("down", "s") then
        local deceleration = self.acceleration * 0.005 * dt -- Calculate deceleration based on ship's acceleration and delta time
        local dotProduct = self.velocity.x * math.sin(self.rotation) + self.velocity.y * -math.cos(self.rotation) -- Calculate dot product of velocity and forward direction
        local directionAngle = self:getDirectionAngle()

        -- Calculate the factor by which to scale the deceleration based on direction angle
        local decelerationFactor = 1 - math.abs(directionAngle) / 90

        if dotProduct > 0 then
            -- Apply deceleration in the forward direction
            self.velocity.x = self.velocity.x - self.velocity.x * deceleration * decelerationFactor
            self.velocity.y = self.velocity.y - self.velocity.y * deceleration * decelerationFactor
        else
            -- Apply deceleration in the backward direction
            self.velocity.x = self.velocity.x + self.velocity.x * deceleration * decelerationFactor
            self.velocity.y = self.velocity.y + self.velocity.y * deceleration * decelerationFactor
        end
    end

    -- Calculate friction based on current velocity (always present)
    local frictionX = -self.velocity.x * self.frictionCoefficient
    local frictionY = -self.velocity.y * self.frictionCoefficient

    -- Add friction to velocity
    self.velocity.x = self.velocity.x + frictionX * dt
    self.velocity.y = self.velocity.y + frictionY * dt

    local minSpeed = 0 -- Limits the minimum speed due to friction
    -- Calculate the total speed (modulo of the velocity vector)
    local speed = self:getSpeed()
    if speed < minSpeed then
        self.velocity.x = 0
        self.velocity.y = 0
    end

    -- If the speed is higher than the maximum speed allowed, it reduces the speed to a fraction of the maximum speed
    if speed > self.maxSpeed then
        local scaleFactor = self.maxSpeed / speed
        self.velocity.x = self.velocity.x * scaleFactor
        self.velocity.y = self.velocity.y * scaleFactor
    end

    -- Update ship's x and y position based on current velocity
    self.x = self.x + self.velocity.x * dt
    self.y = self.y + self.velocity.y * dt
end

-- This draw method defines how the ship is drawn on the screen
function Ship:draw()
    love.graphics.push() -- This function saves the current graphics transformation matrix. It's useful when you want to apply temporary transformations (like rotation or translation) only to a specific part of the drawing, without affecting the rest of the scene
    love.graphics.translate(self.x, self.y) -- This function translates the origin of the graphics coordinates so that it corresponds to the (self.x, self.y) position of the ship. In other words, this instruction moves the coordinate system so that the center of the ship is at coordinates (0, 0)
    love.graphics.rotate(self.rotation) -- This function rotates the coordinate system counterclockwise by an angle of self.rotation in radians
    love.graphics.polygon("fill", 0, -25, -15, 25, 15, 25) -- This instruction draws a filled polygon that represents the ship
    love.graphics.pop() -- This function restores the previous graphics transformation matrix that was saved with push(). This is important to ensure that the transformations don't affect other objects drawn after the ship
end

function Ship:debug()
    local speed = self:getSpeed()
    local directionAngle = self:getDirectionAngle()
    local debugText = {
        "Debug Info:",
        "x: " .. string.format("%.2f", self.x),
        "y: " .. string.format("%.2f", self.y),
        "acceleration: " .. string.format("%.2f", love.keyboard.isDown("w", "up") and self.acceleration or 0) .. " px/s²",
        "brake: " .. (love.keyboard.isDown("s", "down") and "Pressed" or "Not pressed"),
        "rotation: " .. string.format("%.2f", self.rotation % 6.28) .. " rad",
        "velocity: x=" .. string.format("%.2f", self.velocity.x) .. ", y=" .. string.format("%.2f", self.velocity.y),
        "speed: " .. string.format("%.2f", speed) .. " px/s",
        "directionAngle: " .. string.format("%.2f", directionAngle) .. "°",
        "frictionCoefficient: " .. self.frictionCoefficient
    }

    love.graphics.setColor(1, 1, 1)
    local lineHeight = 20
    for i, textLine in ipairs(debugText) do
        love.graphics.print(textLine, 10, 10 + (i - 1) * lineHeight)
    end
end

-- Calculate and return the magnitude of the velocity vector, representing the speed of the ship
function Ship:getSpeed()
    return math.sqrt(self.velocity.x^2 + self.velocity.y^2)
end

-- Calculate and return the direction of the ship in radians based on its velocity vector
function Ship:getShipDirection()
    return math.atan2(self.velocity.y, self.velocity.x);
end

-- Calculate and return the angle of direction (orientation) of the ship in degrees, considering its current rotation
function Ship:getDirectionAngle()
    -- Calculate the ship's direction angle based on its velocity direction and rotation
    local shipDirection = self:getShipDirection()
    local directionAngle = (math.deg(shipDirection - self.rotation) + 90) % 360
    -- Adjust the angle to be within the range [-180, 180]
    if directionAngle > 180 then
        directionAngle = directionAngle - 360
    end

    return directionAngle
end

-- This line returns the Ship table to make the class available for import and use in other files.
return Ship