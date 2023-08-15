local Checkpoint = {} -- Declaration of an empty table named "Checkpoint"
Checkpoint.__index = Checkpoint -- Set the index of the "Checkpoint" table to itself

function Checkpoint.new(x, y, order)
    local self = setmetatable({}, Checkpoint)
    self.x = x
    self.y = y
    self.order = order -- Order/index of the checkpoint
    self.radius = 20 -- Radius of the checkpoint circle
    self.passed = false -- Flag indicating if the ship has passed this checkpoint
    return self
end

function Checkpoint.draw(checkpoints, currentCheckpointIndex)
    for _, checkpoint in ipairs(checkpoints) do
        local text = tostring(checkpoint.order)
        local textWidth = love.graphics.getFont():getWidth(text)
        local textHeight = love.graphics.getFont():getHeight()

        if checkpoint.order == currentCheckpointIndex then
            -- Draw the current checkpoint as a filled circle with a different color
            love.graphics.setColor(0.5, 0.5, 1)
            love.graphics.circle("fill", checkpoint.x, checkpoint.y, checkpoint.radius)

            -- Draw the text label at the center of the filled circle
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(text, checkpoint.x - textWidth / 2, checkpoint.y - textHeight / 2)
        else
            -- Draw other checkpoints as outlined circles with the text label
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", checkpoint.x, checkpoint.y, checkpoint.radius)
            love.graphics.print(text, checkpoint.x - textWidth / 2, checkpoint.y - textHeight / 2)
        end
    end

    love.graphics.setColor(1, 1, 1) -- Reset the color
end

return Checkpoint
