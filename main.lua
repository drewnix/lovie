-- main.lua
-- Entry point for the Lövie application

if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Require the scene manager
-- local SceneManager = require('lib.sceneManager')
local SceneManager = require('lib/sceneManager')

-- Store SceneManager in global table to avoid circular dependencies
_G.SceneManager = SceneManager


-- Load all scenes
local scenes = {
    -- menu = require('scenes.absolute-minimal-menu'),
    menu = require('scenes.diagnostic-menu'),
    -- menu = require('scenes.menu'),
    basic_drawing = require('scenes.basic_drawing'),
    animations = require('scenes.animations'),
    physics = require('scenes.physics'),
    particles = require('scenes.particles'),
    audio = require('scenes.audio'),
    documentation = require('scenes.documentation')
}

function love.load()
    -- Initialize the scene manager with all our scenes
    SceneManager.init(scenes)
    
    -- Start with the menu scene
    SceneManager.switchTo('menu')
    
    -- Set up key bindings
    love.keyboard.keysPressed = {}
end

function love.update(dt)
    -- Pass update to the current scene
    SceneManager.update(dt)
    
    -- Reset keys pressed
    love.keyboard.keysPressed = {}
end

function love.draw()
    -- Pass draw to the current scene
    SceneManager.draw()
    
    -- Display a hint about the menu key
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.printf("Press 'M' for menu", 10, love.graphics.getHeight() - 30, love.graphics.getWidth() - 20, "right")
    love.graphics.setColor(1, 1, 1, 1)
end


function love.keypressed(key)
    -- Debug output
    print("Key pressed: " .. key)
    
    -- Store keys pressed for the current frame (if you're using this)
    if love.keyboard.keysPressed then
        love.keyboard.keysPressed[key] = true
    end
    
    -- Special case for 'M' key to return to menu
    if key == 'm' or key == 'M' then
        print("Menu key detected, current scene: " .. tostring(SceneManager.current))
        
        -- Get list of available scenes
        local availableScenes = {}
        for name, _ in pairs(SceneManager.scenes) do
            table.insert(availableScenes, name)
        end
        print("Available scenes: " .. table.concat(availableScenes, ", "))
        
        -- Try to switch to menu
        if SceneManager.scenes['menu'] then
            SceneManager.switchTo('menu')
        else
            print("WARNING: 'menu' scene does not exist!")
        end
    else
        -- Pass key press to current scene
        if SceneManager.current and SceneManager.scenes[SceneManager.current] and 
           SceneManager.scenes[SceneManager.current].keypressed then
            SceneManager.keypressed(key)
        end
    end
    
    -- Escape key for quitting (useful during testing)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyreleased(key)
    -- Pass key release to current scene
    SceneManager.keyreleased(key)
end

function love.mousepressed(x, y, button)
    -- Pass mouse press to current scene
    SceneManager.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    -- Pass mouse release to current scene
    SceneManager.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
    -- Pass wheel movement to current scene if it has the handler
    if SceneManager.current and SceneManager.scenes[SceneManager.current].wheelmoved then
        SceneManager.scenes[SceneManager.current].wheelmoved(x, y)
    end
end

function love.resize(w, h)
    -- Pass resize event to current scene if it has the handler
    if SceneManager.current and SceneManager.scenes[SceneManager.current].resize then
        SceneManager.scenes[SceneManager.current].resize(w, h)
    end
end

-- Helper function to check if a key was just pressed
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end