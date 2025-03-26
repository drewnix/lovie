-- scenes/animations.lua
-- Demonstrates different animation techniques in LÖVE

local Utils = require('lib.utils')

local Animations = {
    title = "Animations",
    description = "Demonstrates different animation techniques in LÖVE"
}

-- Animation examples
local animations = {}
local elapsedTime = 0
local selectedAnimation = 1

function Animations.enter()
    elapsedTime = 0
    
    -- Reset all animations
    animations = {
        {
            name = "Linear Motion",
            object = {
                x = 100,
                y = 150,
                width = 50,
                height = 50,
                color = {1, 0, 0}
            },
            update = function(self, dt)
                -- Simple oscillation using sine
                self.object.x = 100 + math.sin(elapsedTime) * 100
            end,
            draw = function(self)
                love.graphics.setColor(self.object.color)
                love.graphics.rectangle("fill", self.object.x, self.object.y, self.object.width, self.object.height)
            end,
            description = "Uses sine function to create oscillating motion.\nmath.sin(time) * amplitude"
        },
        {
            name = "Scale Animation",
            object = {
                x = 100,
                y = 250,
                width = 50,
                height = 50,
                scale = 1,
                color = {0, 1, 0}
            },
            update = function(self, dt)
                -- Pulsating scale effect
                self.object.scale = 1 + math.sin(elapsedTime * 2) * 0.5
            end,
            draw = function(self)
                love.graphics.setColor(self.object.color)
                
                -- Draw from center with scale
                love.graphics.push()
                love.graphics.translate(
                    self.object.x + self.object.width / 2,
                    self.object.y + self.object.height / 2
                )
                love.graphics.scale(self.object.scale, self.object.scale)
                love.graphics.rectangle(
                    "fill", 
                    -self.object.width / 2, 
                    -self.object.height / 2, 
                    self.object.width, 
                    self.object.height
                )
                love.graphics.pop()
            end,
            description = "Uses love.graphics.scale to animate size.\nTranslate to center, scale, then draw."
        },
        {
            name = "Color Transition",
            object = {
                x = 100,
                y = 350,
                width = 50,
                height = 50,
                color = {1, 1, 1}
            },
            update = function(self, dt)
                -- Rainbow color effect
                self.object.color[1] = math.abs(math.sin(elapsedTime * 0.5))
                self.object.color[2] = math.abs(math.sin(elapsedTime * 0.5 + math.pi/3))
                self.object.color[3] = math.abs(math.sin(elapsedTime * 0.5 + 2*math.pi/3))
            end,
            draw = function(self)
                love.graphics.setColor(self.object.color)
                love.graphics.rectangle("fill", self.object.x, self.object.y, self.object.width, self.object.height)
            end,
            description = "Animates RGB values using offset sine waves.\nCreates a smooth rainbow effect."
        },
        {
            name = "Rotation",
            object = {
                x = 100,
                y = 450,
                width = 50,
                height = 50,
                rotation = 0,
                color = {1, 1, 0}
            },
            update = function(self, dt)
                -- Continuous rotation
                self.object.rotation = elapsedTime * 2
            end,
            draw = function(self)
                love.graphics.setColor(self.object.color)
                
                -- Draw with rotation
                love.graphics.push()
                love.graphics.translate(
                    self.object.x + self.object.width / 2,
                    self.object.y + self.object.height / 2
                )
                love.graphics.rotate(self.object.rotation)
                love.graphics.rectangle(
                    "fill", 
                    -self.object.width / 2, 
                    -self.object.height / 2, 
                    self.object.width, 
                    self.object.height
                )
                love.graphics.pop()
            end,
            description = "Uses love.graphics.rotate to spin object.\nCombines translate and rotate transforms."
        },
        {
            name = "Easing Animation",
            object = {
                x = 100,
                y = 550,
                targetX = 300,
                startX = 100,
                width = 50,
                height = 50,
                time = 0,
                duration = 2,
                direction = 1,
                color = {0, 1, 1}
            },
            update = function(self, dt)
                -- Easing animation back and forth
                self.object.time = self.object.time + dt * self.object.direction
                
                if self.object.time >= self.object.duration then
                    self.object.time = self.object.duration
                    self.object.direction = -1
                elseif self.object.time <= 0 then
                    self.object.time = 0
                    self.object.direction = 1
                end
                
                -- Cubic easing
                local t = self.object.time / self.object.duration
                local easedT = t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
                
                self.object.x = Utils.lerp(
                    self.object.startX,
                    self.object.targetX,
                    easedT
                )
            end,
            draw = function(self)
                love.graphics.setColor(self.object.color)
                love.graphics.rectangle("fill", self.object.x, self.object.y, self.object.width, self.object.height)
            end,
            description = "Uses cubic easing function for smooth motion.\nEases in and out for natural movement."
        }
    }
end

function Animations.update(dt)
    elapsedTime = elapsedTime + dt
    
    -- Update all animations
    for _, anim in ipairs(animations) do
        anim:update(dt)
    end
end

function Animations.draw()
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw title and description
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(Animations.title, 0, 20, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(Animations.description, 0, 60, love.graphics.getWidth(), "center")
    
    -- Draw animations
    for i, anim in ipairs(animations) do
        -- Draw name
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print(anim.name, 400, anim.object.y)
        
        -- Draw the animation
        anim:draw()
        
        -- Draw description if this is the selected animation
        if i == selectedAnimation then
            love.graphics.setColor(0.1, 0.1, 0.15)
            love.graphics.rectangle("fill", 500, 150, 270, 200)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(love.graphics.newFont(12))
            love.graphics.printf(anim.description, 510, 160, 250, "left")
        end
    end
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("Press UP/DOWN to select different animations", 0, love.graphics.getHeight() - 30, love.graphics.getWidth(), "center")
    
    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function Animations.keypressed(key)
    if key == "up" then
        selectedAnimation = math.max(1, selectedAnimation - 1)
    elseif key == "down" then
        selectedAnimation = math.min(#animations, selectedAnimation + 1)
    end
end

return Animations