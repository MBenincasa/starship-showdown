local Ship = {} -- Declaration of an empty table named "Ship"
Ship.__index = Ship -- Set the index of the "Ship" table to itself

function Ship.new(x, y)
    local self = setmetatable({}, Ship) -- Create a new instance (object) of the Ship class
    self.x = x or 100
    self.y = y or 300
    self.velocity = { x = 0, y = 0 } -- Velocity vector
    self.acceleration = 150 -- Ship acceleration
    self.maxSpeed = 300 -- Maximum speed of the ship
    self.rotation = 0 -- Rotation angle of the ship in radians
    return self
end

-- This update method defines the update behavior of the ship
function Ship:update(dt)
    if love.keyboard.isDown("left", "a") then
        self.rotation = self.rotation - math.rad(100) * dt -- Rotates the ship to the left by subtracting a certain angle in radians
    elseif love.keyboard.isDown("right", "d") then
        self.rotation = self.rotation + math.rad(100) * dt -- Rotate the ship to the right by adding a certain angle in radians
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
        local deceleration = self.acceleration * 0.01 * dt
        -- Reduce the x and y velocity of the ship by multiplying it by the deceleration
        self.velocity.x = self.velocity.x - self.velocity.x * deceleration
        self.velocity.y = self.velocity.y - self.velocity.y * deceleration
    end

    -- Calculate the total speed (modulo of the velocity vector)
    local speed = math.sqrt(self.velocity.x^2 + self.velocity.y^2)
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
    local speed = math.sqrt(self.velocity.x^2 + self.velocity.y^2)
    local debugText = {
        "Debug Info:",
        "x: " .. string.format("%.2f", self.x),
        "y: " .. string.format("%.2f", self.y),
        "acceleration: " .. string.format("%.2f", self.acceleration),
        "rotation: " .. string.format("%.2f", self.rotation),
        "velocity: x=" .. string.format("%.2f", self.velocity.x) .. ", y=" .. string.format("%.2f", self.velocity.y),
        "speed: " .. string.format("%.2f", speed)
    }

    love.graphics.setColor(1, 1, 1)
    local lineHeight = 20
    for i, textLine in ipairs(debugText) do
        love.graphics.print(textLine, 10, 10 + (i - 1) * lineHeight)
    end
end

-- This line returns the Ship table to make the class available for import and use in other files.
return Ship