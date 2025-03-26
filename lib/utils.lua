-- lib/utils.lua
-- Collection of utility functions used across scenes

local Utils = {}

-- Check if a point is inside a rectangle
function Utils.pointInRect(x, y, rx, ry, rw, rh)
    return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

-- Linear interpolation
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Color utilities
function Utils.hexToRGB(hex)
    hex = hex:gsub("#", "")
    return {
        tonumber("0x" .. hex:sub(1, 2)) / 255,
        tonumber("0x" .. hex:sub(3, 4)) / 255,
        tonumber("0x" .. hex:sub(5, 6)) / 255
    }
end

function Utils.setColor(r, g, b, a)
    if type(r) == "table" then
        love.graphics.setColor(r[1], r[2], r[3], g or 1)
    else
        love.graphics.setColor(r, g, b, a or 1)
    end
end

-- Draw a rounded rectangle
function Utils.drawRoundedRect(x, y, width, height, radius)
    radius = radius or 10

    -- Save current graphics state
    love.graphics.push()
    love.graphics.translate(x, y)

    -- Top-left corner
    love.graphics.arc("fill", radius, radius, radius, math.pi, math.pi * 1.5)
    -- Top-right corner
    love.graphics.arc("fill", width - radius, radius, radius, math.pi * 1.5, math.pi * 2)
    -- Bottom-right corner
    love.graphics.arc("fill", width - radius, height - radius, radius, 0, math.pi * 0.5)
    -- Bottom-left corner
    love.graphics.arc("fill", radius, height - radius, radius, math.pi * 0.5, math.pi)

    -- Rectangles to fill the space between arcs
    love.graphics.rectangle("fill", radius, 0, width - radius * 2, height)
    love.graphics.rectangle("fill", 0, radius, width, height - radius * 2)

    love.graphics.pop()
end

-- Create a simple timer
function Utils.createTimer(duration, callback, loops)
    return {
        duration = duration,
        callback = callback,
        loops = loops or 1,
        time = 0,
        active = true,

        update = function(self, dt)
            if not self.active then return end

            self.time = self.time + dt
            if self.time >= self.duration then
                if self.callback then self.callback() end

                if self.loops > 0 then
                    self.loops = self.loops - 1
                    if self.loops == 0 then
                        self.active = false
                    end
                end

                self.time = self.time - self.duration
            end
        end,

        reset = function(self)
            self.time = 0
            self.active = true
        end,

        stop = function(self)
            self.active = false
        end,

        start = function(self)
            self.active = true
        end
    }
end

-- Display formatted text with shadow
function Utils.drawTextWithShadow(text, x, y, shadowOffset, align)
    shadowOffset = shadowOffset or 2
    align = align or "left"

    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.printf(text, x + shadowOffset, y + shadowOffset, love.graphics.getWidth(), align)

    -- Draw text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, x, y, love.graphics.getWidth(), align)
end

-- Create a simple tween function
function Utils.tween(obj, target, duration, easing)
    easing = easing or "linear"

    local tween = {
        obj = obj,
        target = target,
        start = {},
        duration = duration,
        time = 0,
        complete = false,
        easing = easing,

        update = function(self, dt)
            if self.complete then return end

            self.time = self.time + dt
            local progress = math.min(self.time / self.duration, 1)

            -- Apply easing
            local easedProgress = progress -- Linear by default

            if self.easing == "inQuad" then
                easedProgress = progress * progress
            elseif self.easing == "outQuad" then
                easedProgress = progress * (2 - progress)
            elseif self.easing == "inOutQuad" then
                easedProgress = progress < 0.5 and 2 * progress * progress or 1 - math.pow(-2 * progress + 2, 2) / 2
            end

            -- Update all properties
            for k, v in pairs(self.target) do
                if self.obj[k] ~= nil then
                    self.obj[k] = self.start[k] + (self.target[k] - self.start[k]) * easedProgress
                end
            end

            if progress >= 1 then
                self.complete = true
            end
        end,

        reset = function(self)
            self.time = 0
            self.complete = false
            -- Store starting values
            for k, v in pairs(self.target) do
                if self.obj[k] ~= nil then
                    self.start[k] = self.obj[k]
                end
            end
        end
    }

    -- Store starting values
    for k, v in pairs(target) do
        if obj[k] ~= nil then
            tween.start[k] = obj[k]
        end
    end

    return tween
end

-- Generate random ID
function Utils.generateID()
    return string.format("%x%x%x%x%x%x%x%x",
        math.random(0, 0xffff), math.random(0, 0xffff),
        math.random(0, 0xffff), math.random(0, 0xffff),
        math.random(0, 0xffff), math.random(0, 0xffff),
        math.random(0, 0xffff), math.random(0, 0xffff)
    )
end

-- Clamp a value between min and max
function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

return Utils