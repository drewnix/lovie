-- scenes/menu.lua
-- Improved menu scene with better visuals and feedback

local SceneManager = require('lib.sceneManager')
local Button = require('lib.components.button')
local Utils = require('lib.utils')

local Menu = {}

local title = "Lövie Demo Collection"
local subtitle = "A showcase of LÖVE framework features"
local buttons = {}
local buttonHeight = 50
local buttonWidth = 300
local buttonSpacing = 20

-- Additional visual elements
local logoRotation = 0
local backgroundPattern = {}
local fadeInAlpha = 0
local lastMouseX, lastMouseY = 0, 0
local mouseParticles = nil

function Menu.enter()
    print("Menu.enter() called")
    -- Set up buttons for each scene
    buttons = {}

    local sceneNames = SceneManager.getAllSceneNames()
    table.sort(sceneNames)

    local buttonY = 200
    for _, sceneName in ipairs(sceneNames) do
        -- Skip the menu itself
        if sceneName ~= "menu" then
            local displayName = sceneName:gsub("_", " ")
            displayName = displayName:gsub("^%l", string.upper) -- Capitalize first letter

            local button = Button.new(
                (love.graphics.getWidth() - buttonWidth) / 2,
                buttonY,
                buttonWidth,
                buttonHeight,
                displayName,
                {
                    onClick = function()
                        print("Switching to scene: " .. sceneName)
                        SceneManager.switchTo(sceneName)
                    end,
                    -- Use a different color for each button
                    color = generateColorForScene(sceneName)
                }
            )

            table.insert(buttons, button)
            buttonY = buttonY + buttonHeight + buttonSpacing
        end
    end

    -- Initialize background pattern
    backgroundPattern = {}
    for i = 1, 30 do
        table.insert(backgroundPattern, {
            x = math.random() * love.graphics.getWidth(),
            y = math.random() * love.graphics.getHeight(),
            size = math.random(5, 15),
            speed = math.random(10, 30),
            color = {
                math.random(0.2, 0.3),
                math.random(0.2, 0.3),
                math.random(0.3, 0.4),
                math.random(0.5, 0.8)
            }
        })
    end

    -- Initialize mouse particles
    mouseParticles = love.graphics.newParticleSystem(love.graphics.newImage(createCircleImage()), 100)
    mouseParticles:setParticleLifetime(0.5, 1.5)
    mouseParticles:setEmissionRate(10)
    mouseParticles:setSizeVariation(0.5)
    mouseParticles:setLinearAcceleration(-20, -20, 20, 20)
    mouseParticles:setColors(
        1, 1, 1, 0.8,     -- White
        0.5, 0.5, 1, 0.4, -- Light blue
        0, 0, 0, 0        -- Fade out
    )
    mouseParticles:setSizes(0.5, 0.3, 0.1)

    -- Start with fade-in effect
    fadeInAlpha = 0

    -- Store initial mouse position
    lastMouseX, lastMouseY = love.mouse.getPosition()
end

function Menu.update(dt)
    -- Update logo rotation
    logoRotation = logoRotation + dt * 0.2

    -- Update background pattern
    for _, item in ipairs(backgroundPattern) do
        item.y = item.y + item.speed * dt
        if item.y > love.graphics.getHeight() then
            item.y = -item.size
            item.x = math.random() * love.graphics.getWidth()
        end
    end

    -- Update fade-in effect
    if fadeInAlpha < 1 then
        fadeInAlpha = math.min(1, fadeInAlpha + dt * 2)
    end

    -- Update mouse particles
    local mouseX, mouseY = love.mouse.getPosition()
    if math.abs(mouseX - lastMouseX) > 3 or math.abs(mouseY - lastMouseY) > 3 then
        mouseParticles:setPosition(mouseX, mouseY)
        mouseParticles:emit(1)
    end
    lastMouseX, lastMouseY = mouseX, mouseY
    mouseParticles:update(dt)

    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end
end

function Menu.draw()
    -- Reset color and blend mode for safety
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")

    -- Draw background
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw background pattern
    for _, item in ipairs(backgroundPattern) do
        love.graphics.setColor(item.color)
        love.graphics.circle("fill", item.x, item.y, item.size)
    end

    -- Draw decorative header bar
    local headerGradient = {
        0.2, 0.3, 0.4, 1,
        0.3, 0.4, 0.5, 1
    }
    drawGradientBox(0, 0, love.graphics.getWidth(), 120, headerGradient, "vertical")

    -- Draw LÖVE logo
    drawLoveLogo(love.graphics.getWidth() - 80, 60, 50, logoRotation)

    -- Draw title with shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    local titleFont = love.graphics.newFont(32)
    love.graphics.setFont(titleFont)
    love.graphics.printf(title, 3, 33, love.graphics.getWidth(), "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(title, 0, 30, love.graphics.getWidth(), "center")

    -- Draw subtitle
    local subtitleFont = love.graphics.newFont(18)
    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(0.9, 0.9, 1, 0.8)
    love.graphics.printf(subtitle, 0, 80, love.graphics.getWidth(), "center")

    -- Draw mouse particles
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(mouseParticles)

    -- Draw section header
    love.graphics.setColor(0.7, 0.8, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Available Demos", 0, 160, love.graphics.getWidth(), "center")

    -- Draw buttons with fade-in effect
    love.graphics.setColor(1, 1, 1, fadeInAlpha)
    for _, button in ipairs(buttons) do
        button:draw()
    end

    -- Draw footer bar
    drawGradientBox(0, love.graphics.getHeight() - 80, love.graphics.getWidth(), 80, headerGradient, "vertical")

    -- Draw footer text
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(
        "Press 'M' at any time to return to this menu",
        0,
        love.graphics.getHeight() - 50,
        love.graphics.getWidth(),
        "center"
    )

    -- Draw version info
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(
        "LÖVE " .. love._version,
        0,
        love.graphics.getHeight() - 30,
        love.graphics.getWidth() - 20,
        "right"
    )

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function Menu.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        if btn:mousepressed(x, y, button) then
            return
        end
    end
end

function Menu.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        if btn:mousereleased(x, y, button) then
            return
        end
    end
end

function Menu.mousemoved(x, y, dx, dy)
    lastMouseX, lastMouseY = x, y
end

-- Window resize handling
function Menu.resize(w, h)
    -- Recenter all buttons
    local buttonY = 200
    for _, button in ipairs(buttons) do
        button:setPosition((w - buttonWidth) / 2, buttonY)
        buttonY = buttonY + buttonHeight + buttonSpacing
    end
end

-- Helper function to generate a unique color for each scene
function generateColorForScene(sceneName)
    local colors = {
        basic_drawing = { 0.4, 0.6, 0.8 }, -- Blue
        animations = { 0.8, 0.4, 0.6 },  -- Pink
        physics = { 0.4, 0.7, 0.4 },     -- Green
        particles = { 0.7, 0.5, 0.8 },   -- Purple
        audio = { 0.8, 0.7, 0.3 },       -- Gold
        documentation = { 0.5, 0.5, 0.7 } -- Slate blue
    }

    return colors[sceneName] or { 0.4, 0.5, 0.6 } -- Default blue-gray
end

-- Helper function to draw a gradient box - FIXED VERSION
function drawGradientBox(x, y, width, height, colors, direction)
    direction = direction or "horizontal"

    -- Check if we have enough color components
    if #colors < 8 then
        -- Add default values if not enough colors provided
        for i = #colors + 1, 8 do
            colors[i] = colors[i - 4] or 1
        end
    end

    if direction == "horizontal" then
        -- Horizontal gradient
        for i = 0, width - 1 do
            local ratio = i / width
            local r = lerp(colors[1], colors[5], ratio)
            local g = lerp(colors[2], colors[6], ratio)
            local b = lerp(colors[3], colors[7], ratio)
            local a = lerp(colors[4], colors[8], ratio)

            love.graphics.setColor(r, g, b, a)
            love.graphics.rectangle("fill", x + i, y, 1, height)
        end
    else
        -- Vertical gradient
        for i = 0, height - 1 do
            local ratio = i / height
            local r = lerp(colors[1], colors[5], ratio)
            local g = lerp(colors[2], colors[6], ratio)
            local b = lerp(colors[3], colors[7], ratio)
            local a = lerp(colors[4], colors[8], ratio)

            love.graphics.setColor(r, g, b, a)
            love.graphics.rectangle("fill", x, y + i, width, 1)
        end
    end
end

-- Linear interpolation helper
function lerp(a, b, t)
    return a + (b - a) * t
end

-- Draw a stylized LÖVE logo
function drawLoveLogo(x, y, size, rotation)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(rotation)

    -- Draw heart shape
    love.graphics.setColor(1, 0.3, 0.3, 0.9)
    love.graphics.circle("fill", -size / 4, -size / 4, size / 4)
    love.graphics.circle("fill", size / 4, -size / 4, size / 4)
    love.graphics.polygon("fill",
        -size / 2, -size / 4,
        size / 2, -size / 4,
        0, size / 2
    )

    love.graphics.pop()
end

-- Create a circle image for particles
function createCircleImage()
    local size = 32
    local imageData = love.image.newImageData(size, size)

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local dx = x - size / 2
            local dy = y - size / 2
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < size / 2 then
                -- White circle with soft edges
                local alpha = 1 - (distance / (size / 2))
                imageData:setPixel(x, y, 1, 1, 1, alpha)
            else
                -- Transparent outside
                imageData:setPixel(x, y, 0, 0, 0, 0)
            end
        end
    end

    return imageData
end

return Menu
