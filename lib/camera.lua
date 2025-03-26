-- lib/camera.lua
-- A flexible camera system with lerp following, boundaries, and screen shake

local Utils = require('lib.utils')

local Camera = {}
Camera.__index = Camera

-- Create a new camera
function Camera.new(x, y, options)
    local self = setmetatable({}, Camera)

    -- Position
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y

    -- Options
    options = options or {}
    self.rotation = options.rotation or 0
    self.scaleX = options.scaleX or 1
    self.scaleY = options.scaleY or 1
    self.lerpAmount = options.lerpAmount or 0.1 -- How quickly the camera follows the target (0-1)

    -- Bounds
    self.bounds = options.bounds or nil -- {x, y, width, height} or nil for no bounds

    -- Screen shake
    self.shakeIntensity = 0
    self.shakeDuration = 0
    self.shakeTimer = 0
    self.shakeX = 0
    self.shakeY = 0

    -- Deadzone (area where target can move without moving camera)
    self.deadzone = nil -- {x, y, width, height} or nil for no deadzone

    return self
end

-- Move the camera immediately to a position
function Camera:moveTo(x, y)
    self.x = x or self.x
    self.y = y or self.y
    self.targetX = self.x
    self.targetY = self.y

    -- Apply bounds if they exist
    if self.bounds then
        self:applyBounds()
    end
end

-- Set the target position for smooth following
function Camera:follow(target, instant)
    if type(target) == "table" then
        -- Target is a table with x and y
        self.targetX = target.x or self.targetX
        self.targetY = target.y or self.targetY
    else
        -- Target is two separate x, y values
        self.targetX = target or self.targetX
        self.targetY = instant or self.targetY
    end

    if instant then
        self.x = self.targetX
        self.y = self.targetY

        -- Apply bounds if they exist
        if self.bounds then
            self:applyBounds()
        end
    end
end

-- Set camera bounds
function Camera:setBounds(x, y, width, height)
    self.bounds = {
        x = x,
        y = y,
        width = width,
        height = height
    }

    -- Apply bounds immediately
    self:applyBounds()
end

-- Clear camera bounds
function Camera:clearBounds()
    self.bounds = nil
end

-- Set deadzone for camera following
function Camera:setDeadzone(x, y, width, height)
    self.deadzone = {
        x = x,
        y = y,
        width = width,
        height = height
    }
end

-- Clear deadzone
function Camera:clearDeadzone()
    self.deadzone = nil
end

-- Apply bounds to camera position
function Camera:applyBounds()
    if not self.bounds then return end

    -- Calculate visible area in world coordinates
    local visibleWidth = love.graphics.getWidth() / self.scaleX
    local visibleHeight = love.graphics.getHeight() / self.scaleY

    -- Half of the visible area
    local halfWidth = visibleWidth / 2
    local halfHeight = visibleHeight / 2

    -- Apply bounds to target position
    if self.bounds.width > visibleWidth then
        -- Camera can't see the entire bounds width
        self.x = Utils.clamp(self.x, self.bounds.x + halfWidth, self.bounds.x + self.bounds.width - halfWidth)
    else
        -- Center camera on bounds width
        self.x = self.bounds.x + self.bounds.width / 2
    end

    if self.bounds.height > visibleHeight then
        -- Camera can't see the entire bounds height
        self.y = Utils.clamp(self.y, self.bounds.y + halfHeight, self.bounds.y + self.bounds.height - halfHeight)
    else
        -- Center camera on bounds height
        self.y = self.bounds.y + self.bounds.height / 2
    end

    -- Apply to target as well
    self.targetX = self.x
    self.targetY = self.y
end

-- Apply camera transformations to screen
function Camera:attach()
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-self.x - self.shakeX, -self.y - self.shakeY)
end

-- Remove camera transformations
function Camera:detach()
    love.graphics.pop()
end

-- Convert screen coordinates to world coordinates
function Camera:screenToWorld(x, y)
    -- Transform from screen to world coordinates
    local wx = (x - love.graphics.getWidth() / 2) / self.scaleX + self.x
    local wy = (y - love.graphics.getHeight() / 2) / self.scaleY + self.y

    return wx, wy
end

-- Convert world coordinates to screen coordinates
function Camera:worldToScreen(x, y)
    -- Transform from world to screen coordinates
    local sx = (x - self.x) * self.scaleX + love.graphics.getWidth() / 2
    local sy = (y - self.y) * self.scaleY + love.graphics.getHeight() / 2

    return sx, sy
end

-- Shake the camera
function Camera:shake(intensity, duration)
    self.shakeIntensity = intensity or 5
    self.shakeDuration = duration or 0.5
    self.shakeTimer = 0
end

-- Zoom the camera
function Camera:zoom(scale)
    self.scaleX = scale
    self.scaleY = scale
end

-- Update camera position and effects
function Camera:update(dt)
    -- Update screen shake
    if self.shakeDuration > 0 then
        self.shakeTimer = self.shakeTimer + dt

        -- Calculate shake offset
        local progress = self.shakeTimer / self.shakeDuration
        local intensity = self.shakeIntensity * (1 - progress)

        self.shakeX = love.math.random(-intensity, intensity)
        self.shakeY = love.math.random(-intensity, intensity)

        -- End shake if duration exceeded
        if self.shakeTimer >= self.shakeDuration then
            self.shakeDuration = 0
            self.shakeX = 0
            self.shakeY = 0
        end
    end

    -- Apply deadzone for camera following
    if self.deadzone then
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y

        -- Only move camera if target is outside deadzone
        if dx > self.deadzone.width / 2 then
            self.targetX = self.x + dx - self.deadzone.width / 2
        elseif dx < -self.deadzone.width / 2 then
            self.targetX = self.x + dx + self.deadzone.width / 2
        end

        if dy > self.deadzone.height / 2 then
            self.targetY = self.y + dy - self.deadzone.height / 2
        elseif dy < -self.deadzone.height / 2 then
            self.targetY = self.y + dy + self.deadzone.height / 2
        end
    end

    -- Smoothly move camera toward target position
    self.x = Utils.lerp(self.x, self.targetX, self.lerpAmount)
    self.y = Utils.lerp(self.y, self.targetY, self.lerpAmount)

    -- Apply bounds if they exist
    if self.bounds then
        self:applyBounds()
    end
end

return Camera