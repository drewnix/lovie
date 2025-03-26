-- lib/shaderSystem.lua
-- Manages GLSL shaders and shader effects

local ShaderSystem = {
    shaders = {},        -- Dictionary of loaded shaders by name
    activeShader = nil,  -- Currently active shader
    time = 0,            -- Time for shader animations
    defaultCanvas = nil, -- Main canvas for rendering
    effectCanvas = nil,  -- Secondary canvas for effects
    screenWidth = 800,   -- Screen width for shader calculations
    screenHeight = 600   -- Screen height for shader calculations
}

-- Initialize the shader system
function ShaderSystem.init(width, height)
    ShaderSystem.screenWidth = width or love.graphics.getWidth()
    ShaderSystem.screenHeight = height or love.graphics.getHeight()

    -- Create canvases for rendering
    ShaderSystem.defaultCanvas = love.graphics.newCanvas(ShaderSystem.screenWidth, ShaderSystem.screenHeight)
    ShaderSystem.effectCanvas = love.graphics.newCanvas(ShaderSystem.screenWidth, ShaderSystem.screenHeight)

    -- Reset time
    ShaderSystem.time = 0

    return ShaderSystem
end

-- Load a shader from GLSL code
function ShaderSystem.newShader(name, code)
    local shader = love.graphics.newShader(code)
    ShaderSystem.shaders[name] = shader
    return shader
end

-- Get a loaded shader by name
function ShaderSystem.getShader(name)
    return ShaderSystem.shaders[name]
end

-- Set the active shader
function ShaderSystem.setShader(name)
    if name == nil then
        ShaderSystem.activeShader = nil
        return
    end

    local shader = ShaderSystem.shaders[name]
    if shader then
        ShaderSystem.activeShader = shader
    else
        print("Warning: Shader '" .. name .. "' not found")
        ShaderSystem.activeShader = nil
    end
end

-- Update time and shader parameters
function ShaderSystem.update(dt)
    ShaderSystem.time = ShaderSystem.time + dt

    -- Update time uniform for all shaders
    for _, shader in pairs(ShaderSystem.shaders) do
        if shader:hasUniform("time") then
            shader:send("time", ShaderSystem.time)
        end
    end

    -- Update screen dimensions for all shaders
    for _, shader in pairs(ShaderSystem.shaders) do
        if shader:hasUniform("screenSize") then
            shader:send("screenSize", {ShaderSystem.screenWidth, ShaderSystem.screenHeight})
        end
    end
end

-- Begin drawing with the shader system
function ShaderSystem.beginDraw()
    love.graphics.setCanvas(ShaderSystem.defaultCanvas)
    love.graphics.clear()
end

-- End drawing and apply active shader
function ShaderSystem.endDraw()
    -- Switch to effect canvas
    love.graphics.setCanvas(ShaderSystem.effectCanvas)
    love.graphics.clear()

    -- Apply shader if active
    if ShaderSystem.activeShader then
        love.graphics.setShader(ShaderSystem.activeShader)
    end

    -- Draw the default canvas to the effect canvas (with shader applied)
    love.graphics.draw(ShaderSystem.defaultCanvas)

    -- Reset shader
    love.graphics.setShader()

    -- Draw to screen
    love.graphics.setCanvas()
    love.graphics.draw(ShaderSystem.effectCanvas)
end

-- Apply a post-processing effect with parameters
function ShaderSystem.applyEffect(shaderName, params)
    local shader = ShaderSystem.shaders[shaderName]
    if not shader then
        print("Warning: Shader '" .. shaderName .. "' not found")
        return
    end

    -- Set parameters if provided
    if params then
        for name, value in pairs(params) do
            if shader:hasUniform(name) then
                shader:send(name, value)
            end
        end
    end

    -- Store current canvas
    local currentCanvas = love.graphics.getCanvas()

    -- Apply the shader effect between canvases
    love.graphics.setCanvas(ShaderSystem.effectCanvas)
    love.graphics.clear()

    love.graphics.setShader(shader)
    love.graphics.draw(ShaderSystem.defaultCanvas)
    love.graphics.setShader()

    -- Swap canvases to make the effect persistent
    local temp = ShaderSystem.defaultCanvas
    ShaderSystem.defaultCanvas = ShaderSystem.effectCanvas
    ShaderSystem.effectCanvas = temp

    -- Restore previous canvas
    love.graphics.setCanvas(currentCanvas)
end

-- Chain multiple shader effects together
function ShaderSystem.chainEffects(shaderNames, params)
    for i, name in ipairs(shaderNames) do
        ShaderSystem.applyEffect(name, params and params[i])
    end
end

-- Send a uniform value to a specific shader
function ShaderSystem.setUniform(shaderName, uniformName, value)
    local shader = ShaderSystem.shaders[shaderName]
    if shader and shader:hasUniform(uniformName) then
        shader:send(uniformName, value)
    end
end

-- Send a uniform value to all shaders that have it
function ShaderSystem.setGlobalUniform(uniformName, value)
    for _, shader in pairs(ShaderSystem.shaders) do
        if shader:hasUniform(uniformName) then
            shader:send(uniformName, value)
        end
    end
end

-- Resize the shader system
function ShaderSystem.resize(width, height)
    ShaderSystem.screenWidth = width
    ShaderSystem.screenHeight = height

    -- Recreate canvases
    ShaderSystem.defaultCanvas = love.graphics.newCanvas(width, height)
    ShaderSystem.effectCanvas = love.graphics.newCanvas(width, height)

    -- Update screen size uniform for all shaders
    ShaderSystem.setGlobalUniform("screenSize", {width, height})
end

-- Reset the shader system
function ShaderSystem.reset()
    ShaderSystem.activeShader = nil
    ShaderSystem.time = 0
end

return ShaderSystem