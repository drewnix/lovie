-- scenes/documentation.lua
-- Documentation scene showing L�VE framework features

local Documentation = {
    title = "L�VE Documentation",
    description = "Overview of L�VE framework features"
}

-- Content sections
local sections = {
    {
        title = "About L�VE",
        content = "L�VE is a framework for making 2D games in Lua. It's free, open-source, and works on Windows, Mac OS X, Linux, Android and iOS."
    },
    {
        title = "Key Modules",
        content = "L�VE provides several modules:\n- graphics: Drawing shapes, images, text\n- audio: Playing sound effects and music\n- physics: Simulating physical interactions\n- math: Vector math, random numbers\n- filesystem: Reading and writing files"
    },
    {
        title = "Basic Game Loop",
        content = "L�VE uses these main callbacks:\n- love.load(): Initialize your game\n- love.update(dt): Update game logic\n- love.draw(): Draw everything\n- love.keypressed(key): Handle keyboard input"
    }
}

-- State variables
local scroll = 0
local scrollSpeed = 300
local selectedSection = 1

function Documentation.enter()
    print("Entering documentation scene")

    -- Reset scroll position
    scroll = 0
    selectedSection = 1
end

function Documentation.update(dt)
    -- Nothing to update in this simple scene
end

function Documentation.draw()
    -- Draw background
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(28))
    love.graphics.printf(Documentation.title, 0, 30, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(Documentation.description, 0, 70, love.graphics.getWidth(), "center")

    -- Draw content sections
    local y = 120 - scroll
    for i, section in ipairs(sections) do
        -- Draw section background
        if i == selectedSection then
            love.graphics.setColor(0.3, 0.3, 0.5)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end

        local sectionHeight = 80 + string.len(section.content) / 3
        love.graphics.rectangle("fill", 50, y, love.graphics.getWidth() - 100, sectionHeight)

        -- Draw section content
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print(section.title, 70, y + 20)

        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.printf(section.content, 70, y + 50, love.graphics.getWidth() - 140, "left")

        y = y + sectionHeight + 20
    end

    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Use UP/DOWN to scroll, M to return to menu", 0, love.graphics.getHeight() - 30, love.graphics.getWidth(), "center")
end

function Documentation.keypressed(key)
    if key == "up" then
        scroll = math.max(0, scroll - scrollSpeed * 0.1)
    elseif key == "down" then
        scroll = scroll + scrollSpeed * 0.1
    elseif key == "1" or key == "2" or key == "3" then
        selectedSection = tonumber(key)
    end
end

return Documentation