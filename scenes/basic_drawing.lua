-- scenes/basic_drawing.lua
-- Demonstrates basic drawing capabilities in LÖVE

local Utils = require('lib.utils')

local BasicDrawing = {
    title = "Basic Drawing",
    description = "Demonstrates basic shapes and drawing functions in LÖVE"
}

local shapes = {}
local colors = {
    {1, 0, 0},    -- Red
    {0, 1, 0},    -- Green
    {0, 0, 1},    -- Blue
    {1, 1, 0},    -- Yellow
    {1, 0, 1},    -- Magenta
    {0, 1, 1},    -- Cyan
}

function BasicDrawing.enter()
    -- Set up various shapes to demonstrate
    shapes = {
        {
            name = "Rectangle",
            draw = function(x, y)
                love.graphics.rectangle("fill", x, y, 100, 70)
            end
        },
        {
            name = "Circle",
            draw = function(x, y)
                love.graphics.circle("fill", x + 50, y + 35, 35)
            end
        },
        {
            name = "Polygon",
            draw = function(x, y)
                love.graphics.polygon("fill", 
                    x + 50, y,           -- Top
                    x + 100, y + 70,     -- Bottom right
                    x, y + 70            -- Bottom left
                )
            end
        },
        {
            name = "Line",
            draw = function(x, y)
                love.graphics.setLineWidth(5)
                love.graphics.line(x, y, x + 100, y + 70)
                love.graphics.setLineWidth(1)
            end
        },
        {
            name = "Rounded Rectangle",
            draw = function(x, y)
                Utils.drawRoundedRect(x, y, 100, 70, 15)
            end
        },
        {
            name = "Arc",
            draw = function(x, y)
                love.graphics.arc("fill", x + 50, y + 35, 35, 0, math.pi)
            end
        }
    }
end

function BasicDrawing.update(dt)
    -- No update logic needed for this demo
end

function BasicDrawing.draw()
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw title and description
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(BasicDrawing.title, 0, 20, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(BasicDrawing.description, 0, 60, love.graphics.getWidth(), "center")
    
    -- Draw shapes in a grid
    local gridX = 150
    local gridY = 120
    local cellWidth = 150
    local cellHeight = 120
    local columns = 3
    
    for i, shape in ipairs(shapes) do
        local col = (i - 1) % columns
        local row = math.floor((i - 1) / columns)
        
        local x = gridX + col * cellWidth
        local y = gridY + row * cellHeight
        
        -- Draw cell background
        love.graphics.setColor(0.3, 0.3, 0.4)
        love.graphics.rectangle("fill", x - 10, y - 10, cellWidth - 10, cellHeight - 10)
        
        -- Draw shape
        love.graphics.setColor(colors[(i - 1) % #colors + 1])
        shape.draw(x, y + 20)
        
        -- Draw shape name
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.printf(shape.name, x - 10, y - 5, cellWidth - 10, "center")
    end
    
    -- Draw code example
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 500, 350, 270, 200)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    
    local codeExample = [[
-- Drawing shapes in LÖVE
love.graphics.setColor(1, 0, 0)                 -- Red
love.graphics.rectangle("fill", x, y, w, h)     -- Rectangle

love.graphics.setColor(0, 1, 0)                 -- Green
love.graphics.circle("fill", x, y, radius)      -- Circle

love.graphics.setColor(0, 0, 1)                 -- Blue
love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
    ]]
    
    love.graphics.printf(codeExample, 510, 360, 250, "left")
    
    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function BasicDrawing.keypressed(key)
    -- No special key handling for this demo
end

return BasicDrawing