-- scenes/shaders.lua
-- Demonstrates shader effects and post-processing in LÖVE

local Button = require('lib.components.button')
local ShaderSystem = require('lib.shaderSystem')

local Shaders = {
    title = "Shaders",
    description = "Demonstrates post-processing, distortion effects, and lighting",
    category = "Graphics"
}

-- UI elements
local buttons = {}

-- Available shaders
local shaderEffects = {}

-- Game elements
local gameObjects = {}
local player = {
    x = 400,
    y = 300,
    radius = 20,
    speed = 200,
    rotation = 0
}

-- Current state
local currentShaderIndex = 1
local showCode = false
local codeScrollY = 0

-- Define the shaders
local shaderDefinitions = {
    {
        name = "None",
        code = "-- No shader effect",
        description = "Normal rendering without any shader effects."
    },
    {
        name = "Grayscale",
        code = [[
            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                vec4 pixel = Texel(texture, texture_coords);
                float gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
                return vec4(gray, gray, gray, pixel.a) * color;
            }
        ]],
        description = "Converts all colors to grayscale based on luminance."
    },
    {
        name = "Pixelation",
        code = [[
            extern number pixelSize = 4.0;
            extern vec2 screenSize;

            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                // Calculate the pixel grid
                vec2 pixelGrid = floor(texture_coords * screenSize / pixelSize) * pixelSize / screenSize;

                // Sample the texture at the pixelated coordinates
                vec4 pixel = Texel(texture, pixelGrid);

                return pixel * color;
            }
        ]],
        uniforms = {
            pixelSize = 4.0,
        },
        description = "Creates a pixelated effect by reducing the effective resolution."
    },
    {
        name = "Wave Distortion",
        code = [[
            extern number time;
            extern number amplitude = 10.0;
            extern number frequency = 5.0;
            extern number speed = 2.0;

            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                // Create a wave distortion
                vec2 distortedCoords = texture_coords;
                distortedCoords.x += sin(texture_coords.y * frequency + time * speed) * (amplitude / 1000.0);
                distortedCoords.y += cos(texture_coords.x * frequency + time * speed) * (amplitude / 1000.0);

                // Sample the texture at the distorted coordinates
                vec4 pixel = Texel(texture, distortedCoords);

                return pixel * color;
            }
        ]],
        uniforms = {
            amplitude = 10.0,
            frequency = 5.0,
            speed = 2.0
        },
        description = "Creates a wavy distortion effect with adjustable parameters."
    },
    {
        name = "CRT Effect",
        code = [[
            extern number time;
            extern number curvature = 0.1;
            extern number scanlineStrength = 0.5;
            extern vec2 screenSize;

            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                // CRT curvature
                vec2 uv = texture_coords;
                vec2 center = vec2(0.5, 0.5);
                vec2 offset = uv - center;

                // Apply curvature
                float distance = dot(offset, offset) * curvature;
                uv = uv + offset * distance;

                // Check if uv is outside the texture
                if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                    return vec4(0.0, 0.0, 0.0, 1.0);
                }

                // Sample the texture
                vec4 pixel = Texel(texture, uv);

                // Add scanlines
                float scanline = sin(uv.y * screenSize.y * 0.7 + time * 10.0) * 0.5 + 0.5;
                scanline = pow(scanline, 1.0) * scanlineStrength;
                pixel.rgb -= scanline;

                // Add vignette
                float vignette = 1.0 - dot(offset, offset) * 2.0;
                vignette = pow(vignette, 1.5);
                pixel.rgb *= vignette;

                return pixel * color;
            }
        ]],
        uniforms = {
            curvature = 0.1,
            scanlineStrength = 0.5
        },
        description = "Simulates an old CRT display with screen curvature and scanlines."
    },
    {
        name = "Bloom",
        code = [[
            extern number threshold = 0.7;
            extern number intensity = 0.5;

            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                // Sample center pixel
                vec4 pixel = Texel(texture, texture_coords);

                // Sample neighboring pixels for bloom
                const float blurSize = 0.005;
                vec4 bloom = vec4(0.0);

                // 3x3 blur
                for (float y = -1.0; y <= 1.0; y += 1.0) {
                    for (float x = -1.0; x <= 1.0; x += 1.0) {
                        vec2 offset = vec2(x, y) * blurSize;
                        vec4 sample = Texel(texture, texture_coords + offset);

                        // Only bloom bright pixels
                        float brightness = dot(sample.rgb, vec3(0.2126, 0.7152, 0.0722));
                        if (brightness > threshold) {
                            bloom += sample;
                        }
                    }
                }

                bloom /= 9.0; // Average the samples

                // Add bloom to original pixel
                return pixel + bloom * intensity;
            }
        ]],
        uniforms = {
            threshold = 0.7,
            intensity = 0.5
        },
        description = "Creates a bloom effect that makes bright areas glow."
    },
    {
        name = "2D Lighting",
        code = [[
            extern vec2 lightPosition;
            extern vec3 lightColor = vec3(1.0, 0.9, 0.6);
            extern number lightIntensity = 1.0;
            extern number ambientIntensity = 0.2;
            extern vec2 screenSize;

            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                // Sample original pixel
                vec4 pixel = Texel(texture, texture_coords);

                // Calculate normalized light position and screen position
                vec2 lightPos = lightPosition / screenSize;
                vec2 screenPos = screen_coords / screenSize;

                // Calculate distance to light
                float distance = length(lightPos - texture_coords);

                // Calculate light falloff
                float falloff = 1.0 / (1.0 + 3.0 * distance * distance);

                // Apply lighting
                vec3 finalLight = ambientIntensity + lightColor * falloff * lightIntensity;

                // Apply light to pixel color
                vec4 finalColor = vec4(pixel.rgb * finalLight, pixel.a);

                return finalColor * color;
            }
        ]],
        uniforms = {
            lightIntensity = 1.0,
            ambientIntensity = 0.2,
            lightPosition = {400, 300}
        },
        description = "Implements simple 2D lighting with a movable light source."
    }
}

-- Initialize the scene
function Shaders.enter()
    -- Initialize the shader system
    ShaderSystem.init(love.graphics.getWidth(), love.graphics.getHeight())

    -- Create shader objects from definitions
    shaderEffects = {}
    for i, def in ipairs(shaderDefinitions) do
        if def.name ~= "None" then
            -- Create shader
            local shader = ShaderSystem.newShader(def.name, def.code)

            -- Set initial uniforms if any
            if def.uniforms then
                for name, value in pairs(def.uniforms) do
                    if shader:hasUniform(name) then
                        shader:send(name, value)
                    end
                end
            end

            -- Set screen size uniform if needed
            if shader:hasUniform("screenSize") then
                shader:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
            end
        end

        table.insert(shaderEffects, {
            name = def.name,
            description = def.description,
            code = def.code,
            uniforms = def.uniforms
        })
    end

    -- Create random game objects
    gameObjects = {}
    for i = 1, 30 do
        local obj = {
            x = love.math.random(50, love.graphics.getWidth() - 50),
            y = love.math.random(50, love.graphics.getHeight() - 50),
            radius = love.math.random(10, 30),
            rotation = love.math.random() * math.pi * 2,
            rotationSpeed = (love.math.random() - 0.5) * 2, -- -1 to 1
            color = {
                love.math.random(),
                love.math.random(),
                love.math.random()
            },
            shape = love.math.random(1, 3) -- 1: circle, 2: rectangle, 3: triangle
        }
        table.insert(gameObjects, obj)
    end

    -- Create UI buttons for switching shaders
    buttons = {}
    local buttonY = 50
    local buttonHeight = 30
    local buttonWidth = 150
    local buttonX = love.graphics.getWidth() - buttonWidth - 20

    for i, effect in ipairs(shaderEffects) do
        local button = Button.new(
            buttonX,
            buttonY + (i-1) * (buttonHeight + 5),
            buttonWidth,
            buttonHeight,
            effect.name,
            {
                onClick = function()
                    switchShader(i)
                end
            }
        )
        table.insert(buttons, button)
    end

    -- Add view code button
    local codeButton = Button.new(
        buttonX,
        love.graphics.getHeight() - 40,
        buttonWidth,
        buttonHeight,
        "View/Hide Code",
        {
            onClick = function()
                showCode = not showCode
            end
        }
    )
    table.insert(buttons, codeButton)

    -- Set initial shader
    switchShader(1)
end

-- Switch to a different shader
function switchShader(index)
    currentShaderIndex = index

    if index == 1 then
        -- "None" shader
        ShaderSystem.setShader(nil)
    else
        ShaderSystem.setShader(shaderEffects[index].name)
    end
end

function Shaders.update(dt)
    -- Update player movement
    local speed = player.speed
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

    -- Keep player within screen bounds
    player.x = math.max(player.radius, math.min(love.graphics.getWidth() - player.radius, player.x))
    player.y = math.max(player.radius, math.min(love.graphics.getHeight() - player.radius, player.y))

    -- Update player rotation
    player.rotation = player.rotation + dt

    -- Update game objects
    for _, obj in ipairs(gameObjects) do
        obj.rotation = obj.rotation + obj.rotationSpeed * dt
    end

    -- Update light position for 2D lighting shader
    if currentShaderIndex == 7 then -- Assuming 7 is the 2D lighting shader
        local shader = ShaderSystem.getShader("2D Lighting")
        if shader then
            shader:send("lightPosition", {player.x, player.y})
        end
    end

    -- Update shader system
    ShaderSystem.update(dt)

    -- Update UI
    for _, button in ipairs(buttons) do
        button:update(dt)
    end
end

function Shaders.draw()
    -- Try to use shader system safely
    local useShaders = ShaderSystem and type(ShaderSystem) == "table" and type(ShaderSystem.beginDraw) == "function"

    if useShaders then
        -- Begin drawing with shader system
        pcall(function() ShaderSystem.beginDraw() end)
    end

    -- Draw background
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw game objects
    for _, obj in ipairs(gameObjects) do
        love.graphics.setColor(obj.color)

        if obj.shape == 1 then
            -- Circle
            love.graphics.circle("fill", obj.x, obj.y, obj.radius)
        elseif obj.shape == 2 then
            -- Rectangle
            love.graphics.push()
            love.graphics.translate(obj.x, obj.y)
            love.graphics.rotate(obj.rotation)
            love.graphics.rectangle("fill", -obj.radius, -obj.radius, obj.radius * 2, obj.radius * 2)
            love.graphics.pop()
        else
            -- Triangle
            love.graphics.push()
            love.graphics.translate(obj.x, obj.y)
            love.graphics.rotate(obj.rotation)
            local r = obj.radius
            love.graphics.polygon("fill", 0, -r, -r * 0.866, r * 0.5, r * 0.866, r * 0.5)
            love.graphics.pop()
        end
    end

    -- Draw player
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.push()
    love.graphics.translate(player.x, player.y)
    love.graphics.rotate(player.rotation)
    love.graphics.rectangle("fill", -player.radius, -player.radius, player.radius * 2, player.radius * 2)
    love.graphics.pop()

    -- End drawing with shader system (apply shader)
    if useShaders then
        pcall(function() ShaderSystem.endDraw() end)
    end

    -- Draw UI over the shader effect
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(Shaders.title, 20, 20, love.graphics.getWidth() - 200, "left")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(Shaders.description, 20, 60, love.graphics.getWidth() - 200, "left")

    -- Draw shader info
    local currentShader = shaderEffects[currentShaderIndex]
    love.graphics.setColor(1, 0.8, 0.4)
    love.graphics.printf(
        "Current: " .. currentShader.name,
        20, 90, love.graphics.getWidth() - 200, "left"
    )

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(
        currentShader.description,
        20, 120, love.graphics.getWidth() - 200, "left"
    )

    -- Draw UI buttons
    for _, button in ipairs(buttons) do
        button:draw()
    end

    -- Draw controls help
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    local helpY = love.graphics.getHeight() - 70

    love.graphics.printf("Controls: WASD / Arrow Keys = Move Player", 20, helpY, 300, "left")
    love.graphics.printf("Player position affects 2D lighting shader", 20, helpY + 20, 300, "left")

    -- Show code if enabled
    if showCode then
        -- Draw code background
        love.graphics.setColor(0, 0, 0, 0.8)
        local codeWidth = love.graphics.getWidth() - 40
        local codeHeight = love.graphics.getHeight() - 100
        love.graphics.rectangle("fill", 20, 50, codeWidth, codeHeight)

        -- Draw code content
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(12))

        -- Draw shader name
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.printf(
            currentShader.name .. " Shader Code",
            20, 60, codeWidth, "center"
        )

        -- Draw code with syntax highlighting (basic)
        love.graphics.setFont(love.graphics.newFont(12))

        -- Split code into lines
        local lines = {}
        for line in string.gmatch(currentShader.code, "[^\r\n]+") do
            table.insert(lines, line)
        end

        -- Display code with basic syntax highlighting
        local lineHeight = 16
        local startY = 90 - codeScrollY

        for i, line in ipairs(lines) do
            local y = startY + (i-1) * lineHeight

            -- Skip lines outside visible area
            if y > 50 and y < 50 + codeHeight then
                -- Highlight keywords
                local coloredLine = line

                -- Comments (green)
                if string.find(line, "//") then
                    love.graphics.setColor(0.4, 0.8, 0.4)
                -- Keywords (blue)
                elseif string.find(line, "extern") or string.find(line, "vec[234]") or string.find(line, "float") or string.find(line, "number") then
                    love.graphics.setColor(0.4, 0.6, 1.0)
                -- Functions (yellow)
                elseif string.find(line, "effect") or string.find(line, "Texel") or string.find(line, "length") or string.find(line, "dot") then
                    love.graphics.setColor(1.0, 0.8, 0.4)
                -- Default (white)
                else
                    love.graphics.setColor(1, 1, 1)
                end

                love.graphics.print(line, 30, y)
            end
        end

        -- Draw scroll instructions
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("Use mouse wheel to scroll", 20, 50 + codeHeight - 20, codeWidth, "center")
    end
end

function Shaders.keypressed(key)
    -- Any special key handling
end

function Shaders.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if btn:mousepressed(x, y, button) then
                return
            end
        end
    end
end

function Shaders.mousereleased(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if btn:mousereleased(x, y, button) then
                return
            end
        end
    end
end

function Shaders.wheelmoved(x, y)
    -- Scroll code view
    if showCode then
        codeScrollY = math.max(0, codeScrollY - y * 30)
    end
end

function Shaders.resize(w, h)
    -- Update shader system
    ShaderSystem.resize(w, h)

    -- Reposition UI elements
    local buttonHeight = 30
    local buttonWidth = 150
    local buttonX = w - buttonWidth - 20
    local buttonY = 50

    for i, button in ipairs(buttons) do
        if i < #shaderEffects + 1 then
            button:setPosition(buttonX, buttonY + (i-1) * (buttonHeight + 5))
        else
            -- View code button
            button:setPosition(buttonX, h - 40)
        end
    end
end

function Shaders.exit()
    -- Clean up resources
    ShaderSystem.reset()
end

return Shaders