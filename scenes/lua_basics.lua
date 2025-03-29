-- scenes/lua_basics.lua
-- Description of what this scene demonstrates

local Lua_basics = {
    title = "Lua_basics",
    description = "Description of what this scene demonstrates",
    category = "Basics"  -- Category for menu organization
}

function Lua_basics.enter()
    -- Called when entering the scene
    -- Initialize variables, load resources, set up the scene
end

function Lua_basics.exit()
    -- Called when leaving the scene
    -- Clean up resources, stop sounds, etc.
end

function Lua_basics.update(dt)
    -- Called every frame with delta time
    -- Update game logic, animations, etc.
end

function Lua_basics.draw()
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title and description
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(Lua_basics.title, 0, 20, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(Lua_basics.description, 0, 60, love.graphics.getWidth(), "center")

    -- Draw your scene content here

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function Lua_basics.keypressed(key)
    -- Handle key presses
end

function Lua_basics.mousepressed(x, y, button)
    -- Handle mouse presses
end

function Lua_basics.mousereleased(x, y, button)
    -- Handle mouse releases
end

return Lua_basics
