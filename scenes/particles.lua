-- scenes/particles.lua
-- Colorful and high-contrast particle effects

local Particles = {
    title = "Particle Systems Demo",
    description = "Various particle effects"
}

-- Multiple particle systems
local systems = {}

function Particles.enter()
    print("Entering particles scene")
    systems = {}
    
    -- Create particle image (a bright white circle)
    local particleCanvas = love.graphics.newCanvas(32, 32)
    love.graphics.setCanvas(particleCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", 16, 16, 16)
    love.graphics.setCanvas()
    
    -- 1. Fountain - center of screen
    local fountain = love.graphics.newParticleSystem(particleCanvas, 1000)
    fountain:setParticleLifetime(1, 3)
    fountain:setEmissionRate(150)
    fountain:setSizeVariation(0.5)
    fountain:setSizes(0.5, 0.3, 0.1)
    -- Initial velocity - upward
    fountain:setSpeed(400, 600)
    fountain:setDirection(-math.pi/2) -- Upward
    fountain:setSpread(0.6) -- Spread angle
    -- Gravity pulls particles back down
    fountain:setLinearAcceleration(0, 600, 0, 700)
    fountain:setColors(
        0, 0.5, 1, 1,  -- Blue
        0, 0.7, 1, 0.8, -- Light blue
        0, 0.3, 1, 0.5, -- Darker blue
        0, 0, 0.5, 0    -- Fade out
    )
    fountain:setPosition(400, 500)
    
    table.insert(systems, {
        name = "Fountain",
        system = fountain,
        x = 400, 
        y = 500
    })
    
    -- 2. Fire - left side
    local fire = love.graphics.newParticleSystem(particleCanvas, 1000)
    fire:setParticleLifetime(0.5, 1.5)
    fire:setEmissionRate(200)
    fire:setSizeVariation(0.5)
    fire:setSizes(0.2, 0.6, 0.4)
    fire:setLinearAcceleration(-20, -200, 20, -400)
    fire:setColors(
        1, 1, 0, 1,    -- Yellow
        1, 0.5, 0, 1,  -- Orange
        1, 0, 0, 0.8,  -- Red
        0.3, 0, 0, 0   -- Dark red fade out
    )
    fire:setPosition(200, 300)
    fire:setEmissionArea("ellipse", 30, 10, 0, true)
    
    table.insert(systems, {
        name = "Fire",
        system = fire,
        x = 200,
        y = 300
    })
    
    -- 3. Explosion - right side (emit on space key)
    local explosion = love.graphics.newParticleSystem(particleCanvas, 500)
    explosion:setParticleLifetime(0.5, 1.5)
    explosion:setEmissionRate(0) -- No continuous emission
    explosion:setSizeVariation(0.5)
    explosion:setSizes(0.8, 0.6, 0.2)
    explosion:setSpeed(200, 500)
    explosion:setSpread(math.pi*2) -- 360 degrees
    explosion:setColors(
        1, 1, 0, 1,    -- Yellow 
        1, 0.5, 0, 1,  -- Orange
        1, 0, 0, 0.5,  -- Red
        0, 0, 0, 0     -- Fade out
    )
    explosion:setPosition(600, 300)
    -- Initial burst
    explosion:emit(200)
    
    table.insert(systems, {
        name = "Explosion (Space)",
        system = explosion,
        x = 600,
        y = 300
    })
    
    -- Emit initial particles for all systems
    for _, system in ipairs(systems) do
        if system.name ~= "Explosion (Space)" then
            system.system:emit(100)
        end
    end
    
    print("Created " .. #systems .. " particle systems")
end

function Particles.update(dt)
    for _, system in ipairs(systems) do
        system.system:update(dt)
    end
end

function Particles.draw()
    -- Draw background (dark blue)
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print(Particles.title, 50, 50)
    
    -- Draw particles
    love.graphics.setColor(1, 1, 1)
    for _, system in ipairs(systems) do
        -- Draw the particle system
        love.graphics.draw(system.system)
        
        -- Draw system name
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print(system.name, system.x - 50, system.y + 50, 0, 1, 1, 0, 0, 0.5, 0.5)
    end
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Press SPACE to trigger explosion", 50, love.graphics.getHeight() - 50)
    love.graphics.print("Press M to return to menu", 50, love.graphics.getHeight() - 30)
end

function Particles.keypressed(key)
    print("Particles scene received key: " .. key)
    
    if key == "space" then
        -- Find explosion system and emit a burst
        for _, system in ipairs(systems) do
            if system.name == "Explosion (Space)" then
                system.system:emit(200)
                print("Explosion triggered")
                break
            end
        end
    end
end

return Particles