-- lib/resolutionManager.lua
-- Handles different screen resolutions and scaling methods

local ResolutionManager = {
    -- Default screen dimensions
    gameWidth = 800,
    gameHeight = 600,

    -- Physical screen dimensions
    screenWidth = 800,
    screenHeight = 600,

    -- Scaling options
    scaleMode = "fit", -- "fit", "stretch", "pixel-perfect", "integer-scale"

    -- Canvas for rendering at virtual resolution
    canvas = nil,

    -- Scale values
    scaleX = 1,
    scaleY = 1,

    -- Offset for letterboxing/pillarboxing
    offsetX = 0,
    offsetY = 0,

    -- Highest integer scale that fits in the window
    integerScale = 1,

    -- Background color for letterboxing/pillarboxing
    backgroundColor = {0.1, 0.1, 0.12}
}

-- Initialize the resolution manager
function ResolutionManager.init(gameWidth, gameHeight, scaleMode)
    ResolutionManager.gameWidth = gameWidth or 800
    ResolutionManager.gameHeight = gameHeight or 600
    ResolutionManager.scaleMode = scaleMode or "fit"

    -- Create canvas for rendering at virtual resolution
    ResolutionManager.canvas = love.graphics.newCanvas(
        ResolutionManager.gameWidth, 
        ResolutionManager.gameHeight
    )

    -- Set initial screen dimensions
    ResolutionManager.screenWidth = love.graphics.getWidth()
    ResolutionManager.screenHeight = love.graphics.getHeight()

    -- Calculate initial scale and offset
    ResolutionManager.calculateScaleAndOffset()

    return ResolutionManager
end

-- Update screen size when window is resized
function ResolutionManager.handleResize(width, height)
    ResolutionManager.screenWidth = width
    ResolutionManager.screenHeight = height

    -- Recalculate scale and offset
    ResolutionManager.calculateScaleAndOffset()
end

-- Calculate scaling and offset values based on current mode
function ResolutionManager.calculateScaleAndOffset()
    if ResolutionManager.scaleMode == "stretch" then
        -- Stretch to fill screen (may distort aspect ratio)
        ResolutionManager.scaleX = ResolutionManager.screenWidth / ResolutionManager.gameWidth
        ResolutionManager.scaleY = ResolutionManager.screenHeight / ResolutionManager.gameHeight
        ResolutionManager.offsetX = 0
        ResolutionManager.offsetY = 0

    elseif ResolutionManager.scaleMode == "fit" then
        -- Fit inside screen (preserve aspect ratio with letterboxing/pillarboxing)
        local scale = math.min(
            ResolutionManager.screenWidth / ResolutionManager.gameWidth,
            ResolutionManager.screenHeight / ResolutionManager.gameHeight
        )

        ResolutionManager.scaleX = scale
        ResolutionManager.scaleY = scale

        -- Center the game on screen
        ResolutionManager.offsetX = (ResolutionManager.screenWidth - ResolutionManager.gameWidth * scale) / 2
        ResolutionManager.offsetY = (ResolutionManager.screenHeight - ResolutionManager.gameHeight * scale) / 2

    elseif ResolutionManager.scaleMode == "pixel-perfect" then
        -- Use integer scaling for pixel-perfect rendering
        local scaleX = ResolutionManager.screenWidth / ResolutionManager.gameWidth
        local scaleY = ResolutionManager.screenHeight / ResolutionManager.gameHeight

        -- Find the largest integer scale that fits
        ResolutionManager.integerScale = math.max(1, math.floor(math.min(scaleX, scaleY)))

        ResolutionManager.scaleX = ResolutionManager.integerScale
        ResolutionManager.scaleY = ResolutionManager.integerScale

        -- Center the game on screen
        ResolutionManager.offsetX = (ResolutionManager.screenWidth - ResolutionManager.gameWidth * ResolutionManager.integerScale) / 2
        ResolutionManager.offsetY = (ResolutionManager.screenHeight - ResolutionManager.gameHeight * ResolutionManager.integerScale) / 2

    elseif ResolutionManager.scaleMode == "integer-scale" then
        -- Scale by integer values (1x, 2x, 3x, etc.) for nearest-neighbor scaling
        local maxScaleX = ResolutionManager.screenWidth / ResolutionManager.gameWidth
        local maxScaleY = ResolutionManager.screenHeight / ResolutionManager.gameHeight

        -- Find largest integer scale that fits
        local scale = math.floor(math.min(maxScaleX, maxScaleY))
        scale = math.max(1, scale) -- Ensure at least 1x scaling

        ResolutionManager.scaleX = scale
        ResolutionManager.scaleY = scale

        -- Center the game on screen
        ResolutionManager.offsetX = (ResolutionManager.screenWidth - ResolutionManager.gameWidth * scale) / 2
        ResolutionManager.offsetY = (ResolutionManager.screenHeight - ResolutionManager.gameHeight * scale) / 2
    end
end

-- Begin rendering to the virtual resolution canvas
function ResolutionManager.beginDraw()
    -- Switch to the canvas for rendering at the virtual resolution
    love.graphics.setCanvas(ResolutionManager.canvas)
    love.graphics.clear()
end

-- End rendering and draw the canvas to the screen with appropriate scaling
function ResolutionManager.endDraw()
    -- Switch back to the default canvas
    love.graphics.setCanvas()

    -- Draw background color for letterboxing/pillarboxing
    love.graphics.setColor(ResolutionManager.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, ResolutionManager.screenWidth, ResolutionManager.screenHeight)

    -- Reset color
    love.graphics.setColor(1, 1, 1)

    -- Set the scaling filter based on mode
    if ResolutionManager.scaleMode == "pixel-perfect" or ResolutionManager.scaleMode == "integer-scale" then
        -- Use nearest neighbor filtering for pixel art
        love.graphics.setDefaultFilter("nearest", "nearest")
    else
        -- Use linear filtering for smoother scaling
        love.graphics.setDefaultFilter("linear", "linear")
    end

    -- Draw the canvas with appropriate scaling and position
    love.graphics.draw(
        ResolutionManager.canvas, 
        ResolutionManager.offsetX, 
        ResolutionManager.offsetY, 
        0, -- rotation
        ResolutionManager.scaleX, 
        ResolutionManager.scaleY
    )
end

-- Change the scaling mode
function ResolutionManager.setScaleMode(mode)
    ResolutionManager.scaleMode = mode
    ResolutionManager.calculateScaleAndOffset()
end

-- Set the virtual resolution
function ResolutionManager.setGameResolution(width, height)
    ResolutionManager.gameWidth = width
    ResolutionManager.gameHeight = height

    -- Recreate canvas for the new resolution
    ResolutionManager.canvas = love.graphics.newCanvas(width, height)

    -- Recalculate scaling
    ResolutionManager.calculateScaleAndOffset()
end

-- Set background color for letterbox/pillarbox areas
function ResolutionManager.setBackgroundColor(r, g, b)
    if type(r) == "table" then
        ResolutionManager.backgroundColor = r
    else
        ResolutionManager.backgroundColor = {r, g, b}
    end
end

-- Convert screen coordinates to game coordinates
function ResolutionManager.screenToGame(x, y)
    local gameX = (x - ResolutionManager.offsetX) / ResolutionManager.scaleX
    local gameY = (y - ResolutionManager.offsetY) / ResolutionManager.scaleY

    return gameX, gameY
end

-- Convert game coordinates to screen coordinates
function ResolutionManager.gameToScreen(x, y)
    local screenX = x * ResolutionManager.scaleX + ResolutionManager.offsetX
    local screenY = y * ResolutionManager.scaleY + ResolutionManager.offsetY

    return screenX, screenY
end

return ResolutionManager