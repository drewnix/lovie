-- lib/components/button.lua
-- Reusable button component

local Utils = require('lib.utils')

local Button = {}
Button.__index = Button

function Button.new(x, y, width, height, text, options)
    local self = setmetatable({}, Button)

    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text or ""
    self.visible = true
    self.renderOffsetX = 0
    self.renderOffsetY = 0

    options = options or {}
    self.color = options.color or {0.4, 0.5, 0.6}  -- Neutral blue-gray
    self.hoverColor = options.hoverColor or {0.5, 0.6, 0.7}  -- Lighter blue-gray
    self.pressedColor = options.pressedColor or {0.3, 0.4, 0.5}  -- Darker blue-gray
    self.textColor = options.textColor or {1, 1, 1}  -- White text
    self.cornerRadius = options.cornerRadius or 8
    self.onClick = options.onClick
    self.id = options.id or Utils.generateID()

    self.isHovered = false
    self.isPressed = false
    self.isEnabled = true

    return self
end

function Button:update(dt)
    if not self.isEnabled or not self.visible then return end

    local mouseX, mouseY = love.mouse.getPosition()
    self.isHovered = Utils.pointInRect(mouseX, mouseY,
                                      self.x,
                                      self.y + self.renderOffsetY,
                                      self.width,
                                      self.height)

    if self.isPressed and not love.mouse.isDown(1) then
        self.isPressed = false
        if self.isHovered and self.onClick then
            self.onClick()
        end
    end
end

function Button:mousepressed(x, y, button)
    if not self.isEnabled or not self.visible then return false end

    if button == 1 and self.isHovered then
        self.isPressed = true
        return true
    end
    return false
end

function Button:mousereleased(x, y, button)
    if not self.isEnabled or not self.visible then return false end

    if button == 1 and self.isPressed then
        self.isPressed = false
        if self.isHovered and self.onClick then
            self.onClick()
            return true
        end
    end
    return false
end

function Button:draw()
    if not self.visible then return end

    -- Determine the current color based on state
    local currentColor
    if not self.isEnabled then
        currentColor = {0.5, 0.5, 0.5}
    elseif self.isPressed then
        currentColor = self.pressedColor
    elseif self.isHovered then
        currentColor = self.hoverColor
    else
        currentColor = self.color
    end

    -- Calculate render position with offset
    local renderX = self.x + self.renderOffsetX
    local renderY = self.y + self.renderOffsetY

    -- Draw button background
    love.graphics.setColor(currentColor)
    Utils.drawRoundedRect(renderX, renderY, self.width, self.height, self.cornerRadius)

    -- Draw button text
    love.graphics.setColor(self.textColor)
    love.graphics.printf(
        self.text,
        renderX,
        renderY + (self.height / 2) - (love.graphics.getFont():getHeight() / 2),
        self.width,
        "center"
    )

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Button:setEnabled(enabled)
    self.isEnabled = enabled
end

function Button:setPosition(x, y)
    self.x = x
    self.y = y
end

function Button:getPosition()
    return self.x, self.y
end

function Button:setDimensions(width, height)
    self.width = width
    self.height = height
end

function Button:setText(text)
    self.text = text
end

function Button:setOnClick(callback)
    self.onClick = callback
end

function Button:setVisible(visible)
    self.visible = visible
end

function Button:isVisible()
    return self.visible
end

function Button:setRenderOffset(x, y)
    self.renderOffsetX = x
    self.renderOffsetY = y
end

return Button