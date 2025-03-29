-- scenes/camera_systems.lua
-- Demonstrates different camera techniques for 2D games

local Camera = require('lib.camera')
local Button = require('lib.components.button')
local Utils = require('lib.utils')

local CameraSystems = {
    title = "Camera Systems",
    description = "Demonstrates following, lerping, boundaries, and camera effects",
    category = "Systems"
}

-- Player entity that the camera follows
local player = {
    x = 0,
    y = 0,
    width = 30,
    height = 30,
    speed = 200,
    color = {0, 0.8, 1}
}

-- Main camera instance
local camera = nil

-- World dimensions for demonstration
local worldWidth = 2000
local worldHeight = 1500
local gridSize = 50

-- UI elements
local buttons = {}
local activeDemoIndex = 1
local demoNames = {
    "Basic Following",
    "Smooth Lerp",
    "Camera Bounds",
    "Screen Shake",
    "Deadzone",
    "Zoom Effects"
}

-- Current demo state
local currentDemo = demoNames[1]
local showHelpText = true
local shakeIntensity = 3
local shakeDuration = 0.3
local lerpAmount = 0.1
local zoomLevel = 1

-- Demo-specific objects
local targetPoints = {}
local zoomPoints = {}

function CameraSystems.enter()
    -- Reset the player position
    player.x = 0
    player.y = 0

    -- Create the camera
    camera = Camera.new(player.x, player.y, {
        lerpAmount = lerpAmount
    })

    -- Create UI buttons for demo switching
    buttons = {}
    local buttonY = 20
    local buttonWidth = 180
    local buttonHeight = 30
    local buttonX = love.graphics.getWidth() - buttonWidth - 20

    for i, demoName in ipairs(demoNames) do
        local button = Button.new(
            buttonX,
            buttonY + (i-1) * (buttonHeight + 10),
            buttonWidth,
            buttonHeight,
            demoName,
            {
                onClick = function()
                    switchDemo(i)
                end
            }
        )
        table.insert(buttons, button)
    end

    -- Set up target points for the deadzone demo
    targetPoints = {}
    for i = 1, 5 do
        table.insert(targetPoints, {
            x = love.math.random(-worldWidth/2, worldWidth/2),
            y = love.math.random(-worldHeight/2, worldHeight/2),
            active = i == 1
        })
    end

    -- Set up zoom points for the zoom demo
    zoomPoints = {}
    for i = 1, 3 do
        table.insert(zoomPoints, {
            x = love.math.random(-worldWidth/3, worldWidth/3),
            y = love.math.random(-worldHeight/3, worldHeight/3),
            zoom = love.math.random(5, 15) / 10, -- Random zoom between 0.5 and 1.5
            active = false
        })
    end

    -- Start with the first demo
    switchDemo(1)
end

-- Handle switching between demos
function switchDemo(index)
    activeDemoIndex = index
    currentDemo = demoNames[index]

    -- Reset camera and player position
    player.x = 0
    player.y = 0
    camera:moveTo(player.x, player.y)
    camera:zoom(1)
    camera:clearBounds()
    camera:clearDeadzone()
    zoomLevel = 1

    -- Configure camera for specific demos
    if currentDemo == "Basic Following" then
        camera.lerpAmount = 1 -- Instant following
    elseif currentDemo == "Smooth Lerp" then
        camera.lerpAmount = lerpAmount
    elseif currentDemo == "Camera Bounds" then
        -- Set up camera bounds
        local boundX = -worldWidth / 3
        local boundY = -worldHeight / 3
        local boundWidth = worldWidth * 2/3
        local boundHeight = worldHeight * 2/3
        camera:setBounds(boundX, boundY, boundWidth, boundHeight)
    elseif currentDemo == "Screen Shake" then
        -- Nothing specific to set up
    elseif currentDemo == "Deadzone" then
        -- Set up a deadzone
        local deadzoneWidth = 200
        local deadzoneHeight = 150
        camera:setDeadzone(-deadzoneWidth/2, -deadzoneHeight/2, deadzoneWidth, deadzoneHeight)

        -- Move player to first target
        if targetPoints[1] then
            player.x = targetPoints[1].x
            player.y = targetPoints[1].y
            camera:moveTo(player.x, player.y)
        end
    elseif currentDemo == "Zoom Effects" then
        -- Initialize zoom level
        zoomLevel = 1
        camera:zoom(zoomLevel)
    end

    -- Reset zoom points
    for i, point in ipairs(zoomPoints) do
        point.active = false
    end

    showHelpText = true
end

function CameraSystems.update(dt)
    local speed = player.speed

    -- Handle keyboard input for player movement
    local dx, dy = 0, 0

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        dy = dy - 1
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        dy = dy + 1
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        dx = dx - 1
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        dx = dx + 1
    end

    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
    end

    -- Update player position
    player.x = player.x + dx * speed * dt
    player.y = player.y + dy * speed * dt

    -- Keep player within world bounds
    player.x = math.max(-worldWidth/2, math.min(worldWidth/2, player.x))
    player.y = math.max(-worldHeight/2, math.min(worldHeight/2, player.y))

    -- Demo-specific updates
    if currentDemo == "Basic Following" or currentDemo == "Smooth Lerp" then
        -- Follow the player
        camera:follow(player.x, player.y)
    elseif currentDemo == "Camera Bounds" then
        -- Follow the player within boundaries
        camera:follow(player.x, player.y)
    elseif currentDemo == "Screen Shake" then
        -- Follow the player
        camera:follow(player.x, player.y)
    elseif currentDemo == "Deadzone" then
        -- Calculate distances to all targets
        for i, point in ipairs(targetPoints) do
            if point.active then
                -- Check if player is close to the active target
                local dx = point.x - player.x
                local dy = point.y - player.y
                local distance = math.sqrt(dx * dx + dy * dy)

                if distance < 30 then
                    -- Move to next target
                    point.active = false
                    local nextIndex = (i % #targetPoints) + 1
                    targetPoints[nextIndex].active = true
                end

                break
            end
        end

        -- Camera follows player with deadzone
        camera:follow(player.x, player.y)
    elseif currentDemo == "Zoom Effects" then
        -- Check if player is near a zoom point
        for _, point in ipairs(zoomPoints) do
            local dx = point.x - player.x
            local dy = point.y - player.y
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < 100 then
                -- Gradually zoom to the point's zoom level
                zoomLevel = Utils.lerp(zoomLevel, point.zoom, 0.05)
                point.active = true
            else
                point.active = false
            end
        end

        -- If not near any point, gradually return to normal zoom
        local nearPoint = false
        for _, point in ipairs(zoomPoints) do
            if point.active then
                nearPoint = true
                break
            end
        end

        if not nearPoint then
            zoomLevel = Utils.lerp(zoomLevel, 1, 0.05)
        end

        -- Apply zoom level
        camera:zoom(zoomLevel)

        -- Follow player
        camera:follow(player.x, player.y)
    end

    -- Update camera
    camera:update(dt)

    -- Update UI buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end

    -- Hide help text after 3 seconds
    if type(showHelpText) == "number" then
        showHelpText = showHelpText - dt * 1.5  -- Fade out faster (1.5x speed)
        if showHelpText < 0 then
            showHelpText = false
        end
    end
end

function CameraSystems.draw()
    -- Clear the screen
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title and description outside the camera transformation
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(CameraSystems.title, 0, 20, love.graphics.getWidth() - 200, "left")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(CameraSystems.description, 0, 60, love.graphics.getWidth() - 200, "left")

    -- Draw current demo name
    love.graphics.setColor(1, 0.8, 0.4)
    love.graphics.printf("Current: " .. (currentDemo or "None"), 0, 90, love.graphics.getWidth() - 200, "left")

    -- Safety check for camera
    if not camera then
        return
    end

    -- Apply camera transformations
    pcall(function() camera:attach() end)

    -- Draw world grid
    pcall(function() drawGrid() end)

    -- Draw world boundary
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.rectangle("line", -worldWidth/2, -worldHeight/2, worldWidth, worldHeight)

    -- Demo-specific drawing
    if currentDemo == "Camera Bounds" then
        -- Draw camera bounds
        if camera.bounds then
            love.graphics.setColor(0.8, 0.4, 0.4, 0.3)
            love.graphics.rectangle("fill",
                camera.bounds.x,
                camera.bounds.y,
                camera.bounds.width,
                camera.bounds.height
            )

            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line",
                camera.bounds.x,
                camera.bounds.y,
                camera.bounds.width,
                camera.bounds.height
            )
        end
    elseif currentDemo == "Deadzone" then
        -- Draw deadzone
        if camera.deadzone then
            local dx = camera.x + camera.deadzone.x
            local dy = camera.y + camera.deadzone.y

            love.graphics.setColor(0.4, 0.8, 0.4, 0.3)
            love.graphics.rectangle("fill",
                dx,
                dy,
                camera.deadzone.width,
                camera.deadzone.height
            )

            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("line",
                dx,
                dy,
                camera.deadzone.width,
                camera.deadzone.height
            )
        end

        -- Draw target points
        for i, point in ipairs(targetPoints) do
            if point.active then
                love.graphics.setColor(0, 1, 0)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end

            love.graphics.circle("fill", point.x, point.y, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(tostring(i), point.x - 10, point.y - 8, 20, "center")
        end
    elseif currentDemo == "Zoom Effects" then
        -- Draw zoom points
        for i, point in ipairs(zoomPoints) do
            if point.active then
                love.graphics.setColor(1, 0.5, 0)
            else
                love.graphics.setColor(0.7, 0.3, 0)
            end

            love.graphics.circle("fill", point.x, point.y, 20)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(string.format("%.1fx", point.zoom), point.x - 15, point.y - 8, 30, "center")
        end
    end

    -- Draw the player
    love.graphics.setColor(player.color)
    love.graphics.rectangle("fill",
        player.x - player.width/2,
        player.y - player.height/2,
        player.width,
        player.height
    )

    -- Draw a direction indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(
        player.x,
        player.y,
        player.x + player.width/2,
        player.y
    )

    -- Remove camera transformations
    pcall(function() camera:detach() end)

    -- Draw UI elements
    for _, button in ipairs(buttons) do
        if button.draw then
            pcall(function() button:draw() end)
        end
    end

    -- Draw controls help
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    local helpY = love.graphics.getHeight() - 120

    love.graphics.printf("Controls:", 20, helpY, 300, "left")
    love.graphics.printf("WASD / Arrow Keys: Move player", 20, helpY + 25, 300, "left")
    love.graphics.printf("H: Toggle help/explanation text", 20, helpY + 50, 300, "left")

    -- Demo-specific controls
    if currentDemo == "Screen Shake" then
        love.graphics.printf("Space: Trigger screen shake", 20, helpY + 75, 300, "left")
    end

    -- Draw current zoom level for zoom demo
    if currentDemo == "Zoom Effects" then
        love.graphics.printf(string.format("Current zoom: %.2fx", zoomLevel), 20, helpY + 75, 300, "left")
    end

    -- Draw help text overlay
    if showHelpText then
        local alpha = type(showHelpText) == "number" and math.min(1, showHelpText) or 1
        local helpText = getDemoHelpText()

        -- Position in the lower right corner
        local boxWidth = 300
        local boxHeight = 180
        local padding = 20
        local boxX = love.graphics.getWidth() - boxWidth - padding
        local boxY = love.graphics.getHeight() - boxHeight - 50 -- Position above the "Press M for menu" text

        -- Draw background with semi-transparency
        love.graphics.setColor(0, 0, 0, 0.5 * alpha)
        love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)

        -- Draw border
        love.graphics.setColor(0.4, 0.4, 0.6, alpha)
        love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)

        -- Draw title
        love.graphics.setColor(1, 0.8, 0.4, alpha)
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.printf(
            "Demo: " .. currentDemo,
            boxX + 10,
            boxY + 10,
            boxWidth - 20,
            "center"
        )

        -- Draw explanation text
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.setFont(love.graphics.newFont(13))
        love.graphics.printf(
            helpText,
            boxX + 10,
            boxY + 35,
            boxWidth - 20,
            "left"
        )
    end
end

-- Draw a grid to help visualize camera movement
function drawGrid()
    local worldStartX = math.floor(-worldWidth / 2 / gridSize) * gridSize
    local worldEndX = math.ceil(worldWidth / 2 / gridSize) * gridSize
    local worldStartY = math.floor(-worldHeight / 2 / gridSize) * gridSize
    local worldEndY = math.ceil(worldHeight / 2 / gridSize) * gridSize

    -- Draw grid lines
    love.graphics.setColor(0.3, 0.3, 0.4, 0.5)

    -- Vertical lines
    for x = worldStartX, worldEndX, gridSize do
        love.graphics.line(x, worldStartY, x, worldEndY)
    end

    -- Horizontal lines
    for y = worldStartY, worldEndY, gridSize do
        love.graphics.line(worldStartX, y, worldEndX, y)
    end

    -- Draw origin with different color
    love.graphics.setColor(0.7, 0.7, 0.8, 0.8)
    love.graphics.line(0, worldStartY, 0, worldEndY)  -- y-axis
    love.graphics.line(worldStartX, 0, worldEndX, 0)  -- x-axis
end

-- Get help text for the current demo
function getDemoHelpText()
    if currentDemo == "Basic Following" then
        return "The camera follows the player instantly without any smoothing.\n\nThis is useful for games that need precise tracking or pixel-perfect positioning."
    elseif currentDemo == "Smooth Lerp" then
        return "The camera follows the player with smooth interpolation.\n\nThis creates a more natural feel and reduces jarring movements."
    elseif currentDemo == "Camera Bounds" then
        return "The camera is constrained within a defined boundary (red rectangle).\n\nThis prevents the camera from showing areas outside the game world."
    elseif currentDemo == "Screen Shake" then
        return "Press SPACE to trigger a screen shake effect.\n\nScreen shake adds impact to events like explosions, damage, or collisions."
    elseif currentDemo == "Deadzone" then
        return "The green rectangle is a 'deadzone' where the player can move without the camera following.\n\nVisit all numbered points in sequence. This is useful for platformers and action games."
    elseif currentDemo == "Zoom Effects" then
        return "Move near the orange circles to trigger zoom effects.\n\nDynamic zooming can emphasize important areas or create dramatic focus."
    else
        return "Select a camera technique from the buttons on the right."
    end
end

function CameraSystems.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if btn:mousepressed(x, y, button) then
                return
            end
        end
    end
end

function CameraSystems.mousereleased(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if btn:mousereleased(x, y, button) then
                return
            end
        end
    end
end

function CameraSystems.keypressed(key)
    if key == "space" and currentDemo == "Screen Shake" then
        -- Trigger screen shake
        camera:shake(shakeIntensity, shakeDuration)
    elseif key == "h" then
        -- Toggle help text
        if showHelpText then
            showHelpText = false
        else
            showHelpText = 5 -- Show for 5 seconds
        end
    end
end

return CameraSystems