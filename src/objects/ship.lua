local Ship = {} -- Declaration of an empty table named "Ship"
Ship.__index = Ship -- Set the index of the "Ship" table to itself

function Ship.new(x, y, speed)
    local self = setmetatable({}, Ship) -- Create a new instance (object) of the Ship class
    self.x = x or 100
    self.y = y or 300
    self.speed = speed or 200
    return self
end

-- This update method defines the update behavior of the ship
function Ship:update(dt)
    if love.keyboard.isDown("left", "a") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("right", "d") then
        self.x = self.x + self.speed * dt
    end

    if love.keyboard.isDown("up", "w") then
        self.y = self.y - self.speed * dt
    elseif love.keyboard.isDown("down", "s") then
        self.y = self.y + self.speed * dt
    end
end

-- This draw method defines how the ship is drawn on the screen
function Ship:draw()
    love.graphics.rectangle("fill", self.x, self.y, 30, 50)
end

-- This line returns the Ship table to make the class available for import and use in other files.
return Ship