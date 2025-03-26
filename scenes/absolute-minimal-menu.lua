-- absolute-minimal-menu.lua
-- A stripped-down menu with no dependencies

local SceneManager = require('lib.sceneManager')  -- Require ONCE at the top of the file
local AbsoluteMinimalMenu = {}

-- Colors with maximum contrast for visibility
local COLORS = {
    BACKGROUND = {0, 0, 0},       -- Pure black
    TEXT = {1, 1, 1},             -- Pure white
    BUTTON_BG = {1, 0, 0},        -- Bright red
    BUTTON_HOVER = {1, 0.5, 0},   -- Orange
    BUTTON_TEXT = {1, 1, 1}       -- White
}

local buttons = {}
local scenes = {"basic_drawing", "animations", "physics", "particles", "audio", "documentation"}

function AbsoluteMinimalMenu.enter()
    print("AbsoluteMinimalMenu.enter() called")

    -- Clear buttons
    buttons = {}

    -- Create clickable areas for each scene
    local buttonY = 200
    for i, sceneName in ipairs(scenes) do
        table.insert(buttons, {
            text = sceneName:gsub("_", " "):gsub("^%l", string.upper),
            x = 250,
            y = buttonY,
            width = 300,
            height = 50,
            hover = false,
            scene = sceneName
        })
        buttonY = buttonY + 70
    end
end

function AbsoluteMinimalMenu.update(dt)
    -- Check for button hovering
    local mx, my = love.mouse.getPosition()

    for _, button in ipairs(buttons) do
        button.hover = mx >= button.x and mx <= button.x + button.width and
                     my >= button.y and my <= button.y + button.height
    end
end

function AbsoluteMinimalMenu.draw()
    -- Draw pure black background
    love.graphics.setColor(COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title text in white
    love.graphics.setColor(COLORS.TEXT)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("MINIMAL MENU", 0, 50, love.graphics.getWidth(), "center")

    -- Subtitle
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Select a demo scene", 0, 100, love.graphics.getWidth(), "center")

    -- Available scenes
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(
        "Available scenes from SceneManager: " .. table.concat(SceneManager.getAllSceneNames(), ", "),
        50, 150, love.graphics.getWidth() - 100, "center"
    )

    -- Draw extremely visible buttons
    love.graphics.setFont(love.graphics.newFont(18))
    for _, button in ipairs(buttons) do
        -- Button background
        if button.hover then
            love.graphics.setColor(COLORS.BUTTON_HOVER)
        else
            love.graphics.setColor(COLORS.BUTTON_BG)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

        -- Button text
        love.graphics.setColor(COLORS.BUTTON_TEXT)
        love.graphics.printf(
            button.text,
            button.x,
            button.y + 15,
            button.width,
            "center"
        )
    end

    -- Draw instructions
    love.graphics.setColor(COLORS.TEXT)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(
        "Click on a button to view a demo",
        0,
        love.graphics.getHeight() - 50,
        love.graphics.getWidth(),
        "center"
    )

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function AbsoluteMinimalMenu.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        for _, btn in ipairs(buttons) do
            if x >= btn.x and x <= btn.x + btn.width and
               y >= btn.y and y <= btn.y + btn.height then
                btn.isPressed = true
            end
        end
    end
end

function AbsoluteMinimalMenu.mousereleased(x, y, button)
    if button == 1 then -- Left mouse button
        for _, btn in ipairs(buttons) do
            if btn.isPressed and
               x >= btn.x and x <= btn.x + btn.width and
               y >= btn.y and y <= btn.y + btn.height then
                print("Button clicked: " .. btn.text)

                -- Use the SceneManager that was required at the top of the file
                -- DON'T require it again here
                if SceneManager then
                    print("SceneManager available, switching to scene: " .. btn.scene)
                    local availableScenes = SceneManager.getAllSceneNames()
                    print("Available scenes: " .. table.concat(availableScenes, ", "))
                    SceneManager.switchTo(btn.scene)
                else
                    print("ERROR: SceneManager is not available!")
                end

                return true
            end
            btn.isPressed = false
        end
    end
    return false
end

function AbsoluteMinimalMenu.mousemoved(x, y)
    for _, btn in ipairs(buttons) do
        btn.isHovered = x >= btn.x and x <= btn.x + btn.width and
                       y >= btn.y and y <= btn.y + btn.height
    end
end

function AbsoluteMinimalMenu.keypressed(key)
    -- Let users use number keys as shortcuts
    local num = tonumber(key)
    if num and num >= 1 and num <= #buttons then
        local btn = buttons[num]
        print("Button activated via keyboard: " .. btn.text)
        SceneManager.switchTo(btn.scene)
    end
end

return AbsoluteMinimalMenu