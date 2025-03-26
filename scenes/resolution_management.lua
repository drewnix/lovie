-- scenes/resolution_management.lua
-- Demonstrates different resolution and scaling techniques

local Button = require('lib.components.button')
local ResolutionManager = require('lib.resolutionManager')

local ResolutionManagement = {
    title = "Resolution Management",
    description = "Demonstrates scaling, virtual resolution, and pixel-perfect rendering"
}

-- UI elements
local buttons = {}
local resolutionButtons = {}
local scaleModeButtons = {}

-- Available game resolutions for testing
local resolutions = {
    {width = 320, height = 240, name = "320x240"},
    {width = 640, height = 480, name = "640x480"},
    {width = 800, height = 600, name = "800x600"},
    {width = 1280, height = 720, name = "1280x720"},
}

-- Scaling modes
local scaleModes = {
    {mode = "fit", name = "Fit (Maintain Aspect)"},
    {mode = "stretch", name = "Stretch (Fill Screen)"},
    {mode = "pixel-perfect", name = "Pixel-Perfect"},
    {mode = "integer-scale", name = "Integer Scaling"}
}

-- Current settings
local currentResolutionIndex = 3  -- 800x600 default
local currentScaleModeIndex = 1   -- Fit default

-- Test game elements (to show resolution effects)
local gameElements = {
    -- Player character
    player = {
        x = 400,
        y = 300,
        size = 20,
        speed = 200
    },

    -- Background grid
    grid = {
        size = 40,  -- Size of grid cells
        color = {0.3, 0.3, 0.4, 0.5}
    },

    -- Test objects
    objects = {}
}

-- Initialize the scene
function ResolutionManagement.enter()
    -- Create some test objects
    gameElements.objects = {}

    -- Add some random sprites of various sizes
    for i = 1, 50 do
        table.insert(gameElements.objects, {
            x = love.math.random(50, 750),
            y = love.math.random(50, 550),
            size = love.math.random(5, 30),
            color = {
                love.math.random(0.3, 1),
                love.math.random(0.3, 1),
                love.math.random(0.3, 1)
            },
            shape = love.math.random(1, 3)  -- 1: square, 2: circle, 3: triangle
        })
    end

    -- Initialize UI
    initializeUI()

    -- Initialize the resolution manager
    local currentRes = resolutions[currentResolutionIndex]
    local currentScaleMode = scaleModes[currentScaleModeIndex].mode

    ResolutionManager.init(currentRes.width, currentRes.height, currentScaleMode)
end

-- Initialize UI elements
function initializeUI()
    buttons = {}

    -- Resolution buttons
    resolutionButtons = {}
    local buttonX = 20
    local buttonY = 150
    local buttonWidth = 120
    local buttonHeight = 30

    for i, res in ipairs(resolutions) do
        local button = Button.new(
            buttonX,
            buttonY + (i-1) * (buttonHeight + 10),
            buttonWidth,
            buttonHeight,
            res.name,
            {
                onClick = function()
                    changeResolution(i)
                end
            }
        )
        table.insert(resolutionButtons, button)
        table.insert(buttons, button)
    end

    -- Scale mode buttons
    scaleModeButtons = {}
    buttonX = love.graphics.getWidth() - buttonWidth - 20

    for i, scaleMode in ipairs(scaleModes) do
        local button = Button.new(
            buttonX,
            buttonY + (i-1) * (buttonHeight + 10),
            buttonWidth,
            buttonHeight,
            scaleMode.name,
            {
                onClick = function()
                    changeScaleMode(i)
                end
            }
        )
        table.insert(scaleModeButtons, button)
        table.insert(buttons, button)
    end

    -- Reset button
    local resetButton = Button.new(
        love.graphics.getWidth() / 2 - buttonWidth / 2,
        love.graphics.getHeight() - buttonHeight - 20,
        buttonWidth,
        buttonHeight,
        "Reset Window Size",
        {
            onClick = function()
                love.window.setMode(800, 600, {resizable = true})
            end
        }
    )
    table.insert(buttons, resetButton)
end

-- Change the virtual resolution
function changeResolution(index)
    currentResolutionIndex = index
    local res = resolutions[index]

    -- Update the resolution manager
    ResolutionManager.setGameResolution(res.width, res.height)

    -- Reset player position to center of new resolution
    gameElements.player.x = res.width / 2
    gameElements.player.y = res.height / 2
end

-- Change the scaling mode
function changeScaleMode(index)
    currentScaleModeIndex = index
    local mode = scaleModes[index].mode

    -- Update the resolution manager
    ResolutionManager.setScaleMode(mode)
end

function ResolutionManagement.update(dt)
    -- Handle keyboard input for player movement
    local speed = gameElements.player.speed

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        gameElements.player.y = gameElements.player.y - speed * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        gameElements.player.y = gameElements.player.y + speed * dt
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        gameElements.player.x = gameElements.player.x - speed * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        gameElements.player.x = gameElements.player.x + speed * dt
    end

    -- Keep player within game bounds
    local currentRes = resolutions[currentResolutionIndex]
    gameElements.player.x = math.max(0, math.min(currentRes.width, gameElements.player.x))
    gameElements.player.y = math.max(0, math.min(currentRes.height, gameElements.player.y))

    -- Update UI buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end
end

function ResolutionManagement.draw()
    -- Draw title and description before resolution management takes over
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(ResolutionManagement.title, 20, 20, love.graphics.getWidth() - 40, "left")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(ResolutionManagement.description, 20, 60, love.graphics.getWidth() - 40, "left")

    -- Draw current settings information
    local currentRes = resolutions[currentResolutionIndex]
    local currentScaleMode = scaleModes[currentScaleModeIndex]

    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(1, 0.8, 0.4)
    love.graphics.printf(
        string.format(
            "Game Resolution: %s | Scale Mode: %s | Window Size: %dx%d",
            currentRes.name,
            currentScaleMode.name,
            love.graphics.getWidth(),
            love.graphics.getHeight()
        ),
        20, 100, love.graphics.getWidth() - 40, "center"
    )

    -- Begin drawing at virtual resolution
    ResolutionManager.beginDraw()

    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, currentRes.width, currentRes.height)

    -- Draw grid
    drawGrid(currentRes.width, currentRes.height, gameElements.grid.size, gameElements.grid.color)

    -- Draw boundary (to show edges of game resolution)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", 0, 0, currentRes.width, currentRes.height)

    -- Draw coordinate axes
    love.graphics.setColor(0.7, 0.7, 0.8, 0.8)
    love.graphics.line(0, currentRes.height / 2, currentRes.width, currentRes.height / 2)  -- x-axis
    love.graphics.line(currentRes.width / 2, 0, currentRes.width / 2, currentRes.height)  -- y-axis

    -- Draw objects
    for _, obj in ipairs(gameElements.objects) do
        love.graphics.setColor(obj.color)

        if obj.shape == 1 then
            -- Square
            love.graphics.rectangle("fill", obj.x - obj.size/2, obj.y - obj.size/2, obj.size, obj.size)
        elseif obj.shape == 2 then
            -- Circle
            love.graphics.circle("fill", obj.x, obj.y, obj.size/2)
        else
            -- Triangle
            love.graphics.polygon(
                "fill",
                obj.x, obj.y - obj.size/2,
                obj.x - obj.size/2, obj.y + obj.size/2,
                obj.x + obj.size/2, obj.y + obj.size/2
            )
        end
    end

    -- Draw player
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.rectangle(
        "fill",
        gameElements.player.x - gameElements.player.size/2,
        gameElements.player.y - gameElements.player.size/2,
        gameElements.player.size,
        gameElements.player.size
    )

    -- Draw resolution information
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(
        currentRes.name,
        0, 10, currentRes.width, "center"
    )

    -- Draw example pixel art text for pixel-perfect modes
    love.graphics.setFont(love.graphics.newFont(8))
    love.graphics.printf(
        "Pixel text (8px)",
        0, 30, currentRes.width, "center"
    )

    -- Finish drawing at virtual resolution
    ResolutionManager.endDraw()

    -- Draw UI buttons (outside the virtual resolution)
    for _, button in ipairs(buttons) do
        button:draw()
    end

    -- Draw sections
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Game Resolutions:", 20, 130, 120, "left")
    love.graphics.printf("Scaling Modes:", love.graphics.getWidth() - 140, 130, 120, "left")

    -- Draw controls help
    local helpY = love.graphics.getHeight() - 70

    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Controls: WASD / Arrow Keys = Move Player", 20, helpY, 300, "left")
    love.graphics.printf("Resize window to test scaling", 20, helpY + 20, 300, "left")
end

-- Draw a grid
function drawGrid(width, height, gridSize, color)
    love.graphics.setColor(color[1] or 0.5, color[2] or 0.5, color[3] or 0.5, color[4] or 0.3)

    -- Vertical lines
    for x = 0, width, gridSize do
        love.graphics.line(x, 0, x, height)
    end

    -- Horizontal lines
    for y = 0, height, gridSize do
        love.graphics.line(0, y, width, y)
    end
end

function ResolutionManagement.resize(w, h)
    -- Update UI positions
    initializeUI()

    -- Update resolution manager
    ResolutionManager.handleResize(w, h)
end

function ResolutionManagement.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if btn:mousepressed(x, y, button) then
                return
            end
        end
    end
end

function ResolutionManagement.mousereleased(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if btn:mousereleased(x, y, button) then
                return
            end
        end
    end
end

return ResolutionManagement